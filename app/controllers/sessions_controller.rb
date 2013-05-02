class SessionsController < Devise::SessionsController
  before_filter :set_return_to
  before_filter :set_default_remember_me, :only => [:create]
  skip_before_filter :require_no_authentication, :only => [:show] , :if => lambda {|c| request.xhr? }

  layout Proc.new { |c| if c.request.xhr? then false else 'application' end }

  def new
    unless already_signed_in?
      super
    end
  end

  def create
    super
    Track::User.logged_in(current_user, params[:return_to], session[:omniauth])
  end

  private

  def set_default_remember_me
    params[:user][:remember_me] = true if params[:user]
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end

end
