class ApplicationController < ActionController::Base
  before_filter :prepend_view_paths

  force_ssl if: :require_ssl?

  protect_from_forgery
  layout :layout_for_request_type

  before_filter :set_locale
  before_filter :log_out_if_token_exists
  before_filter :log_out_if_sso_logout
  before_filter :redirect_to_set_password_unless_unnecessary
  before_filter :first_time_visited?
  before_filter :store_referal_info
  before_filter :platform_context
  before_filter :register_platform_context_as_lookup_context_detail
  before_filter :redirect_if_marketplace_password_protected
  before_filter :set_raygun_custom_data
  before_filter :filter_out_token

  # We need to persist some mixpanel attributes for subsequent
  # requests.
  after_filter :apply_persisted_mixpanel_attributes
  after_filter :store_client_taggable_events

  def current_user
    super.try(:decorate)
  end

  helper_method :current_instance

  def current_instance
    platform_context.try(:instance)
  end

  def secured_params
    @secured_params ||= SecuredParams.new
  end

  def spree_current_user
    current_user
  end

  def platform_context
    @platform_context = PlatformContext.current
  end

  protected

  def set_locale
    params_locale = params[:language].try(:to_sym)
    user_locale = current_user.try(:language).try(:to_sym)

    locale_service = LocaleService.new(platform_context.instance, params_locale, user_locale, request.fullpath)
    if locale_service.redirect? && request.get? && !request.xhr?
      # Redirect -> This is necessary for proper functionality of the 'current_page?' method
      redirect_to(locale_service.redirect_url, status: 301)
    end

    I18n.locale = locale_service.locale
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
    PlatformContext.current.instance.is_community? ? "community" : "application"
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

  def buyable?
    @buyable ||= platform_context.instance.buyable?
  end

  def bookable?
    @bookable ||= platform_context.instance.bookable?
  end

  def subscribable?
    @subscribable ||= platform_context.instance.subscribable?
  end

  # maybe we will rename project to follow? making this followable? for now this stupid name :)
  def projectable?
    @projectable ||= platform_context.instance.projectable?
  end

  helper_method :buyable?, :bookable?, :projectable?, :subscribable?

  # Provides an EventTracker instance for the current request.
  #
  # Use this for triggering predefined events from actions via
  # the application controllers.
  def event_tracker
    @event_tracker ||= begin
                         Analytics::EventTracker.new(mixpanel, google_analytics)
                       end
  end

  def mixpanel
    @mixpanel ||= begin
                    # Load any persisted session properties
                    session_properties = if cookies.signed[:mixpanel_session_properties].present?
                                           ActiveSupport::JSON.decode(cookies.signed[:mixpanel_session_properties]) rescue nil
                                         end

                    # Gather information about requests
                    request_details = {
                      :current_host => request.try(:host)
                    }

                    # Detect an anonymous identifier, if any.
                    anonymous_identity = cookies.signed[:mixpanel_anonymous_id]

                    AnalyticWrapper::MixpanelApi.new(
                      AnalyticWrapper::MixpanelApi.mixpanel_instance(),
                      :current_user => current_user,
                      :request_details => request_details,
                      :anonymous_identity => anonymous_identity,
                      :session_properties => session_properties,
                      :request_params => params,
                      :request => user_signed_in? ? nil : request # we assume that logged in user is not a bot
                    )
                  end
  end

  helper_method :mixpanel

  def google_analytics
    @google_analytics ||= AnalyticWrapper::GoogleAnalyticsApi.new(current_user)
  end

  helper_method :google_analytics

  # Stores cross-request mixpanel options.
  #
  # We need to load up some persisted properties to automatically assign to events
  # as global properties.
  def apply_persisted_mixpanel_attributes
    cookies.signed.permanent[:mixpanel_anonymous_id] = mixpanel.anonymous_identity
    cookies.signed.permanent[:mixpanel_session_properties] = ActiveSupport::JSON.encode(mixpanel.session_properties)
  end

  # Used in controller actions that require authentication
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def first_time_visited?
    @first_time_visited ||= cookies.count.zero?
  end

  def analytics_apply_user(user, with_alias = true)
    store_user_browser_details(user)
    mixpanel.apply_user(user, :alias => with_alias)
    google_analytics.apply_user(user)
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
  rescue Exception => ex
    Rails.logger.error "Storing user #{user.try(:id)} browser details #{user_agent} failed: #{ex}"
  end

  def current_user=(user)
    analytics_apply_user(user)
  end

  def secure_links?
    require_ssl?
  end

  helper_method :secure_links?

  def nm_force_ssl
    if require_ssl?
      redirect_to url_for(platform_context.secured_constraint.merge(:return_to => params[:return_to]))
    end
  end

  def require_ssl?
    !request.ssl? && platform_context.require_ssl?
  end

  def stored_url_for(resource_or_scope)
    redirect_url = params[:return_to] || session[:user_return_to] || root_path
    session[:user_return_to] = session[:return_to] = nil
    redirect_url
  end

  def after_sign_in_path_for(resource)
    url = stored_url_for(resource)
    url = url_without_authentication_token(url) if url.include?("token")
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
    request.xhr? && current_user ? (render :json => { :redirect => stored_url_for(nil) }) : false
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
    unless response.location.present?
      raise "No redirect url provided. Need to call redirect_to first."
    end

    redirect_json = { redirect: response.location }
    # Clear out existing response
    self.response_body = nil
    render(
      :json => redirect_json,
      :content_type => 'application/json',
      :status => 200
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

  def update_analytics_google_id(user)
    if user
      if user.google_analytics_id != cookies[:google_analytics_id] && cookies[:google_analytics_id].present?
        user.update_attribute(:google_analytics_id, cookies[:google_analytics_id])
      end
    end
  end

  def user_google_analytics_id
    current_user.try(:google_analytics_id) ? current_user.google_analytics_id : cookies.signed[:google_analytics_id]
  end

  helper_method :user_google_analytics_id

  def store_client_taggable_events
    if @event_tracker
      session[:triggered_client_taggable_events] ||= []
      session[:triggered_client_taggable_events] += @event_tracker.triggered_client_taggable_methods
    end
  end

  def get_and_clear_stored_client_taggable_events
    events = session[:triggered_client_taggable_events] || []
    session[:triggered_client_taggable_events] = nil
    events
  end

  helper_method :get_and_clear_stored_client_taggable_events

  def register_lookup_context_detail(detail_name)
    lookup_context.class.register_detail(detail_name.to_sym) { nil }
  end

  def register_platform_context_as_lookup_context_detail
    register_lookup_context_detail(:instance_type_id)
    register_lookup_context_detail(:instance_id)
    register_lookup_context_detail(:transactable_type_id)
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
    if resource.respond_to?('logged_out!')
      resource.logged_out!
    end
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
    parameters = nil if not parameters.present?
    uri.query_values = parameters
    uri.to_s
  end

  def current_ip
    session[:current_ip] ? session[:current_ip] : request.remote_ip
  end

  def find_current_country
    if current_ip && current_ip != '127.0.0.1'
      @country = Geocoder.search(current_ip).first.try(:country)
    end
    @country ||= 'United States'
  rescue
    @country ||= 'United States'
  end

  def set_raygun_custom_data
    return if DesksnearMe::Application.config.silence_raygun_notification
    begin
      Raygun.configuration.custom_data = {
        platform_context: platform_context.to_h,
        request_params: params,
        current_user_id: current_user.try(:id)
      }
    rescue => e
      Rails.logger.debug "Error when preparing Raygun custom_params: #{e}"
    end
  end

  def details_for_lookup
    {
      :instance_type_id => PlatformContext.current.try(:instance_type).try(:id),
      :instance_id => PlatformContext.current.try(:instance).try(:id),
      :transactable_type_id => params[:transactable_type_id].present? ? params[:transactable_type_id].to_i : nil
    }
  rescue
    {
      :instance_type_id => PlatformContext.current.try(:instance_type).try(:id),
      :instance_id => PlatformContext.current.try(:instance).try(:id),
    }
  end

  def ckeditor_pictures_scope(options = {})
    options[:assetable_id] = platform_context.instance.id
    options[:assetable_type] = "Instance"
    ckeditor_filebrowser_scope(options)
  end

  def ckeditor_attachment_files_scope(options = {})
    options[:assetable_id] = platform_context.instance.id
    options[:assetable_type] = "Instance"
    ckeditor_filebrowser_scope(options)
  end

  def ckeditor_before_create_asset(asset)
    asset.assetable = platform_context.instance
    return true
  end

  # Assigns the initial bookings to send to the JS controller from stored reservation request prior
  # to initiating a user session. See Locations::ReservationsController for more details
  def restore_initial_bookings_from_stored_reservation
    if params[:restore_reservations ]&& session[:stored_reservation_location_id]
      @form_trigger = session[:stored_reservation_trigger]["#{@location.id}"].presence || 'Book'
      if session[:stored_reservation_location_id] == @location.id
        @initial_bookings = session[:stored_reservation_bookings]
      elsif session[:stored_recurring_booking_location_id] == @location.id
        @initial_bookings = session[:stored_recurring_booking_bookings]
      end
    else
      @initial_bookings = {}
    end
  end

  def build_approval_request_for_object(object)
    object.approval_requests.to_a.reject! { |ar| !object.approval_request_templates.pluck(:id).include?(ar.approval_request_template_id) }
    if (art = object.approval_request_templates.first).present?
      unless ar = object.approval_requests.find { |approval_request| approval_request.approval_request_template_id == art.id }
        ar = object.approval_requests.build(approval_request_template_id: art.id)
        object.approval_requests << ar
      end
      ar.required_written_verification = art.required_written_verification
      art.approval_request_attachment_templates.each do |arat|
        if ara = current_user.approval_request_attachments.for_request_or_free(ar.id).for_attachment_template(arat.id).first
          ar.approval_request_attachments << ara
        end
      end
    end
    object
  end

  def ckeditor_toolbar_creator
    @ckeditor_toolbar_creator ||= CkeditorToolbarCreator.new(params)
  end

  helper_method :ckeditor_toolbar_creator

  def prepend_view_paths
    prepend_view_path("app/community_views") if PlatformContext.current.instance.is_community?
    prepend_view_path InstanceViewResolver.instance
  end

end

