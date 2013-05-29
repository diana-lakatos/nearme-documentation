class SessionsController < Devise::SessionsController
  before_filter :set_return_to
  before_filter :set_default_remember_me, :only => [:create]
  after_filter :rename_flash_messages, :only => [:new, :create, :destroy]
  skip_before_filter :require_no_authentication, :only => [:show] , :if => lambda {|c| request.xhr? }
  after_filter :render_or_redirect_after_create, :only => [:create]

  layout Proc.new { |c| if c.request.xhr? then false else 'application' end }

  def new
    super unless already_signed_in?
    # populate errors but only if someone tried to submit form
    if !current_user && params[:user] && params[:user][:email] && params[:user][:password]
      render_view_with_errors
    end
  end

  private

  def set_default_remember_me
    params[:user][:remember_me] = true if params[:user]
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end

  def set_email
    @email ||= params[:email]
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
    render :template => "sessions/new"
  end

  # if ajax call has been made from modal and user has been created, we need to tell 
  # Modal that instead of rendering content in modal, it needs to redirect to new page
  def render_or_redirect_after_create
    if request.xhr? && current_user
      render_redirect_url_as_json
    end
  end

end
