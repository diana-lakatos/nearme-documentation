class SessionsController < Devise::SessionsController
  before_filter :set_return_to
  before_filter :set_default_remember_me, :only => [:create]
  after_filter :rename_flash_messages, :only => [:new, :create, :destroy]
  skip_before_filter :require_no_authentication, :only => [:show] , :if => lambda {|c| request.xhr? }

  layout Proc.new { |c| if c.request.xhr? then false else 'application' end }

  def new
    @email ||= params[:email]
    super unless already_signed_in?
  end

  private

  def set_default_remember_me
    params[:user][:remember_me] = true if params[:user]
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end

end
