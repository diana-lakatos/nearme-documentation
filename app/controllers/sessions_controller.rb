class SessionsController < Devise::SessionsController
  before_filter :set_return_to
  before_filter :set_default_remember_me, :only => [:create]
  
  layout Proc.new { |c| if c.request.xhr? then false else 'application' end }
  
  private

  def set_default_remember_me
    params[:user][:remember_me] = true if params[:user]
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end
  
end
