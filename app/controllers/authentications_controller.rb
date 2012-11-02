class AuthenticationsController < ApplicationController

  before_filter :redirect_if_login

  def create
    omniauth = request.env["omniauth.auth"]
    omniauth_params = request.env["omniauth.params"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully." if use_flash_messages?
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to user_registration_url
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Signed in successfully." if use_flash_messages?
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url(:wizard => wizard_id)
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to new_user_session_url
  end

  # Clear any omniauth data stored in session
  def clear
    session[:omniauth] = nil
    head :ok
  end

  private

    def redirect_if_login
      redirect_to :root if user_signed_in?
    end

    def wizard_id
      oparams = request.env['omniauth.params']
      oparams && oparams['wizard']
    end

    def use_flash_messages?
      wizard_id.blank?
    end

    def after_sign_in_path_for(resource)
      if wizard_id
        wizard(wizard_id).url
      else
        super
      end
    end

end
