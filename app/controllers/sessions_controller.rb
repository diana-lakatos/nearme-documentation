class SessionsController < Devise::SessionsController
  before_filter :set_return_to

  private

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end
end
