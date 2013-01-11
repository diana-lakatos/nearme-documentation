class AuthenticationsController < ApplicationController

  before_filter :redirect_if_login

  def create
    omniauth = request.env["omniauth.auth"]
    omniauth_params = request.env["omniauth.params"]
    # check if the user has already used :provider to create an account
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication
      logger.debug "user already has an account created via :provider"
      flash[:notice] = "Signed in successfully." if use_flash_messages?
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      logger.debug "user is already logged in but not via :provider, just adding authentication for him"
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to user_registration_url
    else
      logger.debug "new user"
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        logger.debug "success"
        flash[:notice] = "Signed in successfully." if use_flash_messages?
        sign_in_and_redirect(:user, user)
      else
        logger.debug "error " + user.errors.inspect
        session[:omniauth] = omniauth.except('extra')
        logger.debug "wizard: #{wizard_id}" 
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
