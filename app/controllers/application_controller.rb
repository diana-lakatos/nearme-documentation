# frozen_string_literal: true
require 'user_agent'
require 'addressable/uri'

class ApplicationController < ActionController::Base
  before_action do
    NewRelic::Agent.set_transaction_name(
      "#{PlatformContext.current.instance.id} - #{NewRelic::Agent.get_transaction_name}"
    )
  end
  before_action :validate_request_parameters, if: -> { request.get? }
  before_action :prepend_view_paths

  force_ssl if: :require_ssl?

  protect_from_forgery
  layout :layout_for_request_type

  before_action :redirect_unverified_user, if: -> { platform_context.instance.require_verified_user? }
  before_action :set_i18n_locale
  before_action :set_locale
  before_action :log_out_if_token_exists
  before_action :log_out_if_sso_logout
  before_action :redirect_to_set_password_unless_unnecessary
  before_action :first_time_visited?
  before_action :store_referal_info
  before_action :platform_context
  before_action :register_platform_context_as_lookup_context_detail
  before_action :redirect_if_marketplace_password_protected
  before_action :set_raygun_custom_data
  before_action :filter_out_token
  before_action :sign_out_if_signed_out_from_intel_sso, if: -> { should_log_out_from_intel? }
  before_action :set_paper_trail_whodunnit
  before_action :force_fill_in_wizard_form

  around_action :set_time_zone

  def current_user
    super.try(:decorate)
  end

  def current_instance
    platform_context.try(:instance)
  end
  helper_method :current_instance

  def secured_params
    @secured_params ||= SecuredParams.new
  end

  def platform_context
    @platform_context = PlatformContext.current
  end

  def url_options
    { language: language_url_option }.merge(super)
  end

  protected

  def redirect_unverified_user
    unless current_user&.verified_at.present? || current_user&.admin? || current_user&.instance_admin?
      flash[:warning] = t('flash_messages.need_verification_html')
      redirect_to root_path
    end
  end

  def validate_request_parameters
    RequestParametersValidator.new(params).validate!
  end

  def set_locale
    if request.get? && !request.xhr? && language_router.redirect? && params[:format] != 'rss'
      params_with_language = params.merge(language_router.url_params)
      redirect_to url_for(params_with_language)
    end
  end

  def set_i18n_locale
    I18n.locale = language_service.get_language
    session[:language] = I18n.locale
  end

  def language_router
    @language_router ||= if language_service.available_languages.many?
                           Language::MultiLanguageRouter.new(params[:language], I18n.locale)
                         else
                           Language::SingleLanguageRouter.new(params[:language])
                         end
  end

  def language_service
    @language_service ||= Language::LanguageService.new(
      language_params,
      fallback_languages,
      current_instance.available_locales
    )
  end

  def language_params
    [params[:language]]
  end

  def fallback_languages
    [
      session[:language],
      current_user.try(:language),
      current_instance.try(:primary_locale),
      I18n.default_locale
    ]
  end

  def language_url_option
    PlatformContext.current&.url_locale
  end

  def set_time_zone(&block)
    time_zone = current_user.try(:time_zone).presence || current_instance.try(:time_zone).presence || 'UTC'
    Time.use_zone(time_zone, &block)
  end

  def assign_transactable_type_id_to_lookup_context(&_block)
    lookup_context.transactable_type_id ||= @transactable_type.try(:id)
  end

  # Returns the layout to use for the current request.
  #
  # By default this is 'application', except for XHR requests where
  # we use no layout.
  def layout_for_request_type
    if request.xhr?
      false
    else
      layout_name
    end
  end

  def layout_name
    PlatformContext.current.instance.is_community? ? 'community' : 'application'
  end

  def dashboard_or_community_layout
    PlatformContext.current.instance.is_community? ? 'community' : 'dashboard'
  end

  # This method invalidates default PlatformContext and ensures that our scope is Instance [ disregarding listings_public for relevant models ].
  # It should be used whenever we don't want default scoping based on domain for some part of app. That's the case for example for
  # instance_admin (for example we want instance admins to be able to access administrator panel via any white label company ), dashboard (we
  # want white label company creator to manage its private company via instance domain ). Remember, that if this method is used, we are no
  # longer scoping for white label / partner. It means, we should manually ensure we scope correctly ( for example in Dashboard ).
  def force_scope_to_instance
    PlatformContext.scope_to_instance
  end

  def authenticate_scope!
    super
    set_cache_buster
  end

  def authorizer
    @authorizer ||= InstanceAdminAuthorizer.new(current_user)
  end

  helper_method :authorizer

  def bookable?
    @bookable ||= platform_context.instance.bookable?
  end

  # maybe we will rename project to follow? making this followable? for now this stupid name :)
  def projectable?
    @projectable ||= platform_context.instance.projectable?
  end

  helper_method :bookable?, :projectable?

  # Used in controller actions that require authentication
  def set_cache_buster
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def first_time_visited?
    @first_time_visited ||= cookies.count.zero?
  end

  def store_user_browser_details(user)
    if user
      user_agent = UserAgent.parse(request.user_agent)
      if user_agent
        user.browser = user_agent.browser if user_agent.browser
        user.browser_version = user_agent.version.to_s if user_agent.version
        user.platform = user_agent.platform if user_agent.platform
        user.save! if user.changed?
      end
    end
  rescue StandardError => ex
    Rails.logger.error "Storing user #{user.try(:id)} browser details #{user_agent} failed: #{ex}"
  end

  def secure_links?
    require_ssl?
  end

  helper_method :secure_links?

  def nm_force_ssl
    redirect_to url_for(platform_context.secured_constraint.merge(return_to: params[:return_to])) if require_ssl?
  end

  def require_ssl?
    !request.ssl? && platform_context.require_ssl?
  end

  def stored_url_for(_resource_or_scope)
    redirect_url = session[:user_return_to].presence || params[:return_to].presence || root_path
    session[:user_return_to] = session[:return_to] = nil
    redirect_url
  end

  def after_sign_in_path_for(resource)
    force_profile = params[:user] ? params[:user][:force_profile] : nil
    if force_profile.present? && force_profile != 'default' && resource.send("get_#{force_profile}_profile").try(:onboarding?) && !resource.send("get_#{force_profile}_profile").enabled?
      session[:after_onboarding_path] = session[:user_return_to]
      session[:user_return_to] = send("edit_dashboard_#{force_profile}_path")
    end
    url = stored_url_for(resource)
    url = url_without_authentication_token(url) if url.include?('token')
    url = add_login_token_to_url(url, resource) if redirect_to_different_host?(url)
    url
  end

  def redirect_to_different_host?(url)
    uri = Addressable::URI.parse(url)
    uri.host && (uri.host != request.host)
  end

  def add_login_token_to_url(url, resource)
    verifier = User::TemporaryTokenVerifier.new(resource)
    token = verifier.generate(1.day.from_now)
    uri = Addressable::URI.parse(url)
    parameters = uri.query_values || {}
    parameters[:token] = token
    uri.query_values = parameters
    uri.to_s
  end

  def filter_out_token
    redirect_to url_without_authentication_token(request.original_url) if params[TemporaryTokenAuthenticatable::PARAMETER_NAME]
  end

  def after_sign_up_path_for(resource)
    url_without_authentication_token(stored_url_for(resource))
  end

  def already_signed_in?
    request.xhr? && current_user ? (render json: { redirect: stored_url_for(nil) }) : false
  end

  # Some generic information on wizard for use accross controllers
  WizardInfo = Struct.new(:id, :url)

  # Return an object with information for a given wizard
  def wizard(name)
    return name if WizardInfo === name

    case name.to_s
    when 'space'
      WizardInfo.new(name.to_s, new_space_wizard_url)
    when 'onboarding'
      WizardInfo.new(name.to_s, onboarding_index_url)
    end
  end

  helper_method :wizard

  def redirect_for_wizard(wizard_id_or_object)
    redirect_to wizard(wizard_id_or_object).url
  end

  # Clears out the current response data and instead outputs json with
  # a 200 OK status code in the format:
  # { 'redirect': 'url' }
  #
  # Client-side AJAX handlers should handle the redirect.
  #
  # This is to work around browsers redirecting within the AJAX handler,
  # where instead we want the user to do a full page reload.
  #
  # Assumes that the current response is a redirect.
  def render_redirect_url_as_json
    raise 'No redirect url provided. Need to call redirect_to first.' unless response.location.present?

    redirect_json = { redirect: response.location }
    # Clear out existing response
    self.response_body = nil
    render(
      json: redirect_json,
      content_type: 'application/json',
      status: 200
    )
  end

  def render_redirect_as_script
    raise 'No redirect url provided. Need to call redirect_to first.' unless response.location.present?

    redirect_script = "document.location = '#{response.location}'"
    self.response_body = nil
    render(
      js: redirect_script,
      status: 200
    )
  end

  def store_referal_info
    if first_time_visited?
      session[:referer] = request.referer
      if params[:source] && params[:campaign]
        cookies.signed.permanent[:source] = params[:source]
        cookies.signed.permanent[:campaign] = params[:campaign]
      end
    end
  end

  def register_lookup_context_detail(detail_name)
    lookup_context.class.register_detail(detail_name.to_sym) { nil }
  end

  def register_platform_context_as_lookup_context_detail
    register_lookup_context_detail(:instance_id)
    register_lookup_context_detail(:i18n_locale)
    register_lookup_context_detail(:transactable_type_id)
    register_lookup_context_detail(:custom_theme_id)
  end

  def log_out_if_token_exists
    if current_user && params[TemporaryTokenAuthenticatable::PARAMETER_NAME].present?
      Rails.logger.info "#{current_user.email} is being logged out due to token param"
      sign_out current_user
    end
  end

  def log_out_if_sso_logout
    if current_user && current_user.sso_log_out?
      current_user.logged_out!
      flash[:notice] = nil
      sign_out current_user
    end
  end

  def sign_in_resource(resource)
    sign_in(resource)
    resource.logged_out! if resource.respond_to?('logged_out!')
  end

  def redirect_if_marketplace_password_protected
    bypass = session["authenticated_in_marketplace_#{platform_context.instance.id}".to_sym] || params[:controller] =~ /^webhooks\//
    if platform_context.instance.password_protected? && !bypass
      if current_user.nil? || !InstanceAdminAuthorizer.new(current_user).instance_admin?
        session[:marketplace_return_to] = request.path if request.get? && !request.xhr?
        redirect_to main_app.new_marketplace_session_path
      end
    end
  end

  def redirect_to_set_password_unless_unnecessary
    redirect_to set_password_path if set_password_necessary?
  end

  def set_password_necessary?
    return false unless current_user
    current_user.encrypted_password.blank? && current_user.authentications.empty?
  end

  def url_without_authentication_token(url)
    uri = Addressable::URI.parse(url)
    parameters = uri.query_values
    parameters.try(:delete, TemporaryTokenAuthenticatable::PARAMETER_NAME)
    parameters = nil unless parameters.present?
    uri.query_values = parameters
    uri.to_s
  end

  def current_ip
    session[:current_ip] ? session[:current_ip] : request.remote_ip
  end

  def find_current_country
    @country = Geocoder.search(current_ip).first.try(:country) if current_ip && current_ip != '127.0.0.1'
    @country ||= 'United States'
  rescue
    @country ||= 'United States'
  end

  def set_raygun_custom_data
    return if Rails.application.config.silence_raygun_notification
    begin
      Raygun.configuration.custom_data = {
        platform_context: platform_context.to_h,
        request_params: params.reject { |k, _v| Rails.application.config.filter_parameters.include?(k.to_sym) },
        current_user_id: current_user.try(:id),
        process_pid: Process.pid,
        process_ppid: Process.ppid,
        git_version: Rails.application.config.git_version
      }
    rescue => e
      Rails.logger.debug "Error when preparing Raygun custom_params: #{e}"
    end
  end

  def details_for_lookup
    PlatformContext.current.overwrite_custom_theme(current_user)
    set_i18n_locale if @language_service.nil? && !Rails.env.test?
    {
      instance_id: PlatformContext.current.try(:instance).try(:id),
      i18n_locale: I18n.locale,
      custom_theme_id: PlatformContext.current.try(:custom_theme).try(:id),
      transactable_type_id: @transactable_type.try(:id) || (params[:transactable_type_id].present? ? (TransactableType.find_by(slug: params[:transactable_type_id]).try(:id) || params[:transactable_type_id]).to_i : nil)
    }
  rescue
    {
      instance_id: PlatformContext.current.try(:instance).try(:id),
      i18n_locale: I18n.locale,
      custom_theme_id: PlatformContext.current.try(:custom_theme).try(:id)
    }
  end

  def enable_ckeditor_for_field?(model, field)
    FormAttributes::CKEFIELDS.fetch(model.to_sym, []).include?(field.to_sym)
  end

  def ckeditor_before_create_asset(asset)
    # We set id/type manually to avoid having
    # UserDecorator under some circumstances here
    asset.assetable_id = current_user.id
    asset.assetable_type = 'User'
    true
  end

  def build_approval_request_for_object(object)
    ApprovalRequestInitializer.new(object, current_user).process
  end

  def ckeditor_toolbar_creator
    @ckeditor_toolbar_creator ||= CkeditorToolbarCreator.new(params)
  end

  helper_method :ckeditor_toolbar_creator, :enable_ckeditor_for_field?

  def prepend_view_paths
    prepend_view_path("app/#{custom_view_path}_views") if custom_view_path.present?
    prepend_view_path InstanceViewResolver.instance
  end

  def custom_view_path
    # FIXME: tmp hack to fallback to 'intel' for is community
    if PlatformContext.current.instance.is_community?
      PlatformContext.current.instance.prepend_view_path.presence || 'devmesh'
    else
      PlatformContext.current.instance.prepend_view_path
    end
  end

  # It's a valid single param, not an array, hash etc. or some other thing
  def is_valid_single_param?(param)
    if param.present?
      # This will raise an exception if it's not convertible to integer
      param.to_i
    end
    true
  rescue
    false
  end

  def user_for_paper_trail
    user_signed_in? ? current_user.id : PaperTrail.whodunnit
  end

  def sign_out_if_signed_out_from_intel_sso
    signed_out_from_sso = (cookies['SecureSESSION'].nil? && cookies['SMSESSION'].nil?) || (cookies['SecureSESSION'] == 'LOGGEDOFF' && cookies['SMSESSION'] == 'LOGGEDOFF')
    if signed_out_from_sso
      sign_out(current_user)
      cookies.delete('SecureSESSION') && cookies.delete('SMSSESSION')
    end
  end

  def should_log_out_from_intel?
    PlatformContext.current.instance.id == 132 &&
      current_user.present? &&
      !current_user.admin? &&
      !Rails.env.test? &&
      !Rails.env.staging? &&
      !session[:instance_admin_as_user].present?
  end

  def date_time_handler
    @date_time_handler ||= DateTimeHandler.new
  end

  def force_fill_in_wizard_form
    if PlatformContext.current.instance.try(:force_fill_in_wizard_form?) && current_user && !session[:instance_admin_as_user]
      if current_user.seller_profile && current_user.companies.none?
        flash[:error] = t('flash_messages.authorizations.not_filled_form')
        redirect_to PlatformContext.current.instance.transactable_types.first.wizard_path
      elsif current_user.buyer_profile && !current_user.buyer_profile.valid?
        flash[:error] = t('flash_messages.authorizations.not_filled_form')
        redirect_to dashboard_profile_path
      end
    end
  end

  # This will no longer be needed in Rails 5
  def redirect_back_or_default(default = root_path, options = {})
    redirect_to (request.referer.present? ? :back : default), options
  end
end
