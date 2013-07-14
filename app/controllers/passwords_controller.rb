class PasswordsController < Devise::PasswordsController
  before_filter :set_return_to, :only => [:new, :create]
  after_filter :rename_flash_messages, only: [:create]
  after_filter :render_or_redirect_after_create, only: [:create]
  layout Proc.new { |c| if c.request.xhr? then false else 'application' end }

  private

  def after_sending_reset_password_instructions_path_for(resource)
    stored_url_for(resource)
  end

  def render_or_redirect_after_create
    if request.xhr? and successfully_sent?(resource)
      render_redirect_url_as_json
    end
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end

end
