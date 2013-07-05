class AuthenticationsController < ApplicationController


  def create
    omniauth = request.env["omniauth.auth"]
    oauth = Auth::Omni.new(omniauth)
    if oauth.already_connected?(current_user)
      flash[:error] = 'The social provider you have chosen is already connected to other user. Please log out first if you want to log in to other account.' if use_flash_messages?
      redirect_to edit_user_registration_path
    elsif oauth.email_taken?
      flash[:error] = t('omniauth.email_taken_html', provider: omniauth['provider'].titleize,
                        sign_in_link: view_context.link_to('sign in' ,new_user_session_path),
                        recovery_link: view_context.link_to('recover your password' ,new_user_password_path))
      redirect_to root_path
    elsif oauth.authentication
      flash[:success] = 'Signed in successfully.' if use_flash_messages?
      oauth.remember_user!
      sign_in_and_redirect(:user, oauth.authenticated_user)
    elsif current_user
      oauth.create_authentication!(current_user)
      flash[:success] = 'Authentication successful.'
      redirect_to edit_user_registration_url
    else
      if oauth.create_user
        flash[:success] = 'Signed in successfully.' if use_flash_messages?
        oauth.remember_user!
        sign_in_and_redirect(:user, oauth.authenticated_user)
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
      flash[:deleted] = "Successfully disconnected your #{@authentication.provider_name}"
    else
      flash[:warning] = "We are unable to disconnect your account from #{@authentication.provider_name}. Make sure you have at least one other account linked so you can log in!"
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
