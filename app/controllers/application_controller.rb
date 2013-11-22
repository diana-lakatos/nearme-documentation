class ApplicationController < ActionController::Base

  prepend_view_path FooterResolver.instance
  before_filter :require_ssl
  before_filter :log_out_if_token_exists
  before_filter :redirect_to_set_password_unless_unnecessary

  protect_from_forgery
  layout :layout_for_request_type

  # We need to persist some mixpanel attributes for subsequent
  # requests.
  after_filter :apply_persisted_mixpanel_attributes
  after_filter :store_client_taggable_events
  before_filter :first_time_visited?
  before_filter :store_referal_info
  before_filter :platform_context
  before_filter :register_platform_context_as_lookup_context_detail
  before_filter :redirect_if_domain_not_valid


  def current_user
    super.try(:decorate)
  end

  protected

  # Returns the layout to use for the current request.
  #
  # By default this is 'application', except for XHR requests where
  # we use no layout.
  def layout_for_request_type
    if request.xhr?
      false
    else
      "application"
    end
  end

  def platform_context
    @platform_context ||= PlatformContext.new(request.host)
  end

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
        :current_instance_id => platform_context.instance.id,
        :current_host => request.try(:host)
      }

      # Detect an anonymous identifier, if any.
      anonymous_identity = cookies.signed[:mixpanel_anonymous_id]

      AnalyticWrapper::MixpanelApi.new(
        AnalyticWrapper::MixpanelApi.mixpanel_instance(),
        :current_user       => current_user,
        :request_details    => request_details,
        :anonymous_identity => anonymous_identity,
        :session_properties => session_properties,
        :request_params     => params
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

  def require_ssl
    return if Rails.env.development? || Rails.env.test?

    unless request.ssl?
      redirect_to "https://#{request.host}#{request.fullpath}"
    end
  end

  def stored_url_for(resource_or_scope)
    redirect_url = session[:user_return_to] || root_path
    session[:user_return_to] = nil
    redirect_url
  end

  def after_sign_in_path_for(resource)
    url_without_authentication_token(stored_url_for(resource))
  end

  def after_sign_up_path_for(resource)
    url_without_authentication_token(stored_url_for(resource))
  end

  def already_signed_in?
    request.xhr? && current_user ?  (render :json => { :redirect => stored_url_for(nil) }) : false
  end

  # Some generic information on wizard for use accross controllers
  WizardInfo = Struct.new(:id, :url)

  # Return an object with information for a given wizard
  def wizard(name)
    return name if WizardInfo === name

    case name.to_s
    when 'space'
      WizardInfo.new(name.to_s, new_space_wizard_url)
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

    redirect_json = {redirect: response.location}
    # Clear out existing response
    self.response_body = nil
    render(
      :json => redirect_json,
      :content_type => 'application/json',
      :status => 200
    )
  end

  def paper_trail_enabled_for_controller
    devise_controller? ? false : true
  end

  def store_referal_info
    if first_time_visited?
      cookies.signed.permanent[:referer] = request.referer
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

  def search_scope
    @search_scope ||= Listing::SearchScope.scope(platform_context)
  end
  helper_method :search_scope

  def register_lookup_context_detail(detail_name)
    lookup_context.class.register_detail(detail_name.to_sym) { nil }
  end

  def register_platform_context_as_lookup_context_detail
    register_lookup_context_detail(:platform_context)
  end

  def log_out_if_token_exists
    if current_user && params[:token].present?
      Rails.logger.info "#{current_user.email} is being logged out due to token param"
      sign_out current_user
    end
  end

  def redirect_if_domain_not_valid
    redirect_to domain_not_configured_path unless platform_context.valid_domain?
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
    parameters.try(:delete, 'token')
    uri.query_values = parameters
    uri.to_s
  end

  def current_ip
    session[:current_ip] ? session[:current_ip] : request.remote_ip
  end

  def find_current_country
    if current_ip && current_ip != '127.0.0.1'
      @country = Geocoder.search(current_ip).first.country
    else
      @country = 'United States'
    end
  end

end
