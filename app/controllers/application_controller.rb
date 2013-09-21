class ApplicationController < ActionController::Base

  before_filter :require_ssl

  protect_from_forgery
  layout :layout_for_request_type

  # We need to persist some mixpanel attributes for subsequent
  # requests.
  after_filter :apply_persisted_mixpanel_attributes
  before_filter :first_time_visited?
  before_filter :store_referal_info
  before_filter :load_request_context

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

  def load_request_context
    @current_domain = Domain.find_for_request(request)
    if @current_domain && @current_domain.white_label_enabled?
      if @current_domain.white_label_company?
        @current_white_label_company = @current_domain.target
        @current_instance = @current_white_label_company.instance
        @current_theme = @current_domain.target.theme
      elsif @current_domain.instance?
        @current_instance = @current_domain.target
        @current_theme = @current_instance.theme
      end
    else
      @current_instance = Instance.default_instance
      @current_theme = @current_instance.theme
    end
  end
  attr_accessor :current_instance, :current_theme
  helper_method :current_instance, :current_theme

  # Provides an EventTracker instance for the current request.
  #
  # Use this for triggering predefined events from actions via
  # the application controllers.
  def event_tracker
    @event_tracker ||= begin
      Analytics::EventTracker.new(mixpanel, google_analytics).enqueue
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
        :current_instance_id => current_instance.try(:id),
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
    stored_url_for(resource)
  end

  def after_sign_up_path_for(resource)
    stored_url_for(resource)
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

  def handle_invalid_mobile_number(user)
    Delayed::Job.enqueue Delayed::PerformableMethod.new(user, :notify_about_wrong_phone_number, nil)
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

end

