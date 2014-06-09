class SessionsController < Devise::SessionsController
  skip_before_filter :redirect_to_set_password_unless_unnecessary, :only => [:destroy]
  before_filter :sso_logout, :only => [:destroy]
  before_filter :clear_return_to, :only => [:new]
  before_filter :set_return_to
  skip_before_filter :require_no_authentication, :only => [:show] , :if => lambda {|c| request.xhr? }
  skip_before_filter :redirect_if_marketplace_password_protected, :only => [:store_correct_ip]
  after_filter :render_or_redirect_after_create, :only => [:create]
  before_filter :force_ssl, :only => [:new]
  layout :resolve_layout

  def require_no_authentication
    log_out_if_sso_logout
    super unless current_user
  end

  def new
    super unless already_signed_in?
    # populate errors but only if someone tried to submit form
    if !current_user && params[:user] && params[:user][:email] && params[:user][:password]
      render_view_with_errors
    end
  end

  def create
    super

    if current_user
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

  def sso_logout
    current_user.log_out! if current_user
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end

  def clear_return_to
    session[:user_return_to] = nil if login_from_instance_admin? && request.referrer && !request.referrer.include?('instance_admin')
  end

  def resolve_layout
    if request.xhr?
      false
    elsif login_from_instance_admin?
      'instance_admin'
    else
      'application'
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
    (request.referrer && request.referrer.include?('instance_admin')) ? instance_admin_login_path : root_path
  end

end

