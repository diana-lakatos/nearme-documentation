# frozen_string_literal: true
class PasswordsController < Devise::PasswordsController
  skip_before_action :redirect_unverified_user
  before_action :set_return_to, only: [:new, :create]
  skip_before_action :require_no_authentication, only: [:new], if: ->(_c) { request.xhr? }
  before_action :redirect_if_logged_in, only: [:new], if: ->(_c) { request.xhr? }
  after_action :render_or_redirect_after_create, only: [:create]

  private

  def after_sending_reset_password_instructions_path_for(resource)
    stored_url_for(resource)
  end

  def redirect_if_logged_in
    if current_user
      redirect_to root_path
      render_redirect_url_as_json
    end
  end

  def render_or_redirect_after_create
    render_redirect_url_as_json if request.xhr? && successfully_sent?(resource)
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to]
  end
end
