class AuthenticationsController < ApplicationController

  before_filter :initialize_oauth, :only => :create

  def create
    # if we are logged in as X, and we try to connect authentication that belongs to Y, we raise this error to prevent re-logging. 
    if @oauth.already_connected?(current_user)
      already_connected_to_other_user
    # Usual scenario - user already used social provider to log in to our system, everything in db is already set up
    elsif @oauth.authentication
      signed_in_successfully
      # It should not be possible anymore to hit this error. If user authenticated with email A, then changed it to email B, and someone else
      # created a new user for email A, then this error would be raised. We shouldn't reach it though, because the previous 'if' is true
    elsif @oauth.email_taken_by_other_user?(current_user)
      user_changed_email_and_someone_else_picked_it
    # There is no authentication in our system, but user is logged in - we just add authentications to his account
    elsif current_user
      new_authentication_for_existing_user
    # There is no authentication in our system, and the user is not logged in. Hence, we create a new user and then new authentication
    else
      if @oauth.create_user
        # User and authentication created successfully. User is now logged in
        new_user_created_successfully
      else
        # something went wrong while creating a user - most likely provider did not return email. We will ask user to provide one via normal form.
        failed_to_create_new_user
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

  def initialize_oauth
    @omniauth = request.env["omniauth.auth"]
    @oauth = Auth::Omni.new(@omniauth)
  end

  def already_connected_to_other_user
    flash[:error] = 'The social provider you have chosen is already connected to other user. Please log out first if you want to log in to other account.' if use_flash_messages?
    redirect_to edit_user_registration_path
  end

  def signed_in_successfully
    flash[:success] = 'Signed in successfully.' if use_flash_messages?
    @oauth.remember_user!
    sign_in_and_redirect(:user, @oauth.authenticated_user)
  end

  def user_changed_email_and_someone_else_picked_it
    flash[:error] = t('omniauth.email_taken_html', provider: @omniauth['provider'].titleize,
      sign_in_link: view_context.link_to('sign in', new_user_session_path),
      recovery_link: view_context.link_to('recover your password', new_user_password_path))
    redirect_to root_path
  end

  def new_authentication_for_existing_user
    @oauth.create_authentication!(current_user)
    flash[:success] = 'Authentication successful.'
    redirect_to edit_user_registration_url
  end

  def new_user_created_successfully
    @oauth.authenticated_user
    event_tracker.signed_up(@oauth.authenticated_user, { signed_up_via: 'other', provider: @omniauth['provider'] })
    @oauth.remember_user!
    flash[:success] = 'Signed in successfully.' if use_flash_messages?
    sign_in_and_redirect(:user, @oauth.authenticated_user)
  end

  def failed_to_create_new_user
    session[:omniauth] = @omniauth.except('extra')
    redirect_to new_user_registration_url(:wizard => wizard_id)
  end

end
