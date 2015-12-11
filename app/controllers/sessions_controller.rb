class SessionsController < Devise::SessionsController
  skip_before_filter :redirect_to_set_password_unless_unnecessary, only: [:destroy]
  before_filter :sso_logout, only: [:destroy]
  before_filter :omniauth_login, only: [:new]
  skip_before_filter :require_no_authentication, only: [:show] , if: lambda { |c| request.xhr? }
  skip_before_filter :redirect_if_marketplace_password_protected, only: [:store_correct_ip]
  after_filter :render_or_redirect_after_create, only: [:create]
  before_filter :nm_force_ssl, only: [:new]
  layout :resolve_layout

  def require_no_authentication
    log_out_if_sso_logout
    super unless current_user
  end

  def new
    super unless already_signed_in?

    if !flash[:failed_login_attempt_with_email].blank?
      params[:user] = { :email => flash[:failed_login_attempt_with_email], :password => '' }
    end

    # populate errors but only if someone tried to submit form
    if !current_user && params[:user] && params[:user][:email] && params[:user][:password]
      render_view_with_errors
    else
      set_return_to
    end
  end

  def create
    if params[:user] && params[:user][:email]
      flash[:failed_login_attempt_with_email] = params[:user][:email].to_s[0..100]
    end

    super

    if current_user
      # The request was not interrupted by Devise and we also have a current_user object, which
      # means it succeeded so we clear our flash variable
      flash[:failed_login_attempt_with_email] = nil

      current_user.remember_me!
      update_analytics_google_id(current_user)
      analytics_apply_user(current_user)
      event_tracker.logged_in(current_user, provider: Auth::Omni.new(session[:omniauth]).provider)
    end
  end

  def store_correct_ip
    session[:current_ip] = params[:ip]
    render :nothing => true
  end

  private

  def omniauth_login
    provider = PlatformContext.current.instance.default_oauth_signin_provider
    if provider.present? && !login_from_instance_admin?
      path = "/auth/#{provider}"
      p = params.except(:action, :controller)
      path << "?#{p.to_query}" if p.present?
      redirect_to path
    end
  end

  def sso_logout
    current_user.log_out! if current_user
  end

  def set_return_to
    # We can't prevent Devise from setting return_to to users/sign_in on unsuccessful sign in
    # so we then prevent saving it if present
    #

    disallowed_regex = /(users\/sign_in|users\/password)/
    if params[:return_to].present? && !params[:return_to].to_s.match(disallowed_regex)
      session[:user_return_to] = params[:return_to]
    end
  end

  def resolve_layout
    if request.xhr?
      false
    elsif login_from_instance_admin?
      'instance_admin'
    else
      layout_name
    end
  end

  def render_view_with_errors
    flash[:alert] = nil
    self.response_body = nil
    self.resource.email = params[:user][:email]
    if User.find_by_email(params[:user][:email])
      self.resource.errors.add(:password, 'incorrect password')
    else
      self.resource.errors.add(:email, 'incorrect email')
    end
    render :template => login_from_instance_admin? ? "instance_admin/sessions/new" : "sessions/new"
  end

  def login_from_instance_admin?
    session[:user_return_to] && session[:user_return_to].include?('instance_admin')
  end

  # if ajax call has been made from modal and user has been created, we need to tell
  # Modal that instead of rendering content in modal, it needs to redirect to new page
  def render_or_redirect_after_create
    if request.xhr? && current_user
      render_redirect_url_as_json
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    if PlatformContext.current.instance.is_community?
      "https://signin.intel.com/Logout"
    else
      (request.referrer && request.referrer.include?('instance_admin')) ? instance_admin_login_path : root_path
    end
  end

end

