# frozen_string_literal: true
class PasswordsController < Devise::PasswordsController
  skip_before_action :redirect_unverified_user
  before_action :set_return_to, only: [:new, :create]
  skip_before_action :require_no_authentication, only: [:new], if: ->(_c) { request.xhr? }
  before_action :redirect_if_logged_in, only: [:new], if: ->(_c) { request.xhr? }
  after_action :render_or_redirect_after_create, only: [:create]

  def update
    # We can't use Devise validatable as it would interfere with our own
    # email and password validations
    if params[:user][:password] == params[:user][:password_confirmation]
      super
    else
      self.resource = User.find_by(
        reset_password_token: Devise.token_generator.digest(
          nil, :reset_password_token, resource_params[:reset_password_token]
        )
      )
      self.resource.reset_password_token = resource_params[:reset_password_token]
      flash[:error] = t('reset_password_form.password_confirmation_doesnt_match')
      render :edit
    end
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      if PlatformContext.current.instance.id == 5011
        resource.touch(:verified_at) unless resource.verified_at.present?
      end
    else
      flash[:notice] = I18n.t('devise.passwords.send_instructions')
    end

    respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
  end

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
