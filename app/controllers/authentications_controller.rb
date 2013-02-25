class AuthenticationsController < ApplicationController


  def create
    omniauth = request.env["omniauth.auth"]
    omniauth_params = request.env["omniauth.params"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully." if use_flash_messages?
      authentication.user.remember_me!
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      current_user.use_social_provider_image(omniauth['info']['image'])
      current_user.save!
      flash[:notice] = "Authentication successful."
      redirect_to edit_user_registration_url
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Signed in successfully." if use_flash_messages?
        user.remember_me!
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url(:wizard => wizard_id)
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    if @authentication.can_be_deleted?
      @authentication.destroy
      flash[:notice] = "Successfully disconnected your #{@authentication.provider_name}"
    else
      flash[:error] = "We are unable to disconnect your account from #{@authentication.provider_name}. Make sure you have at least one other account linked so you can log in!"
    end
    redirect_to edit_user_registration_url
  end

  # Clear any omniauth data stored in session
  def clear
    session[:omniauth] = nil
    head :ok
  end

  def failure
    flash[:error] = "We are sorry, but we could not authenticate you for the following reason: '#{params[:message] ? params[:message] : "Unknown"}'. Please try again."
    redirect_to new_user_session_url
  end

  private

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
