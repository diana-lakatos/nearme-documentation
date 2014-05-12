class RegistrationsController < Devise::RegistrationsController

  skip_before_filter :redirect_to_set_password_unless_unnecessary, :only => [:update_password, :set_password]
  skip_before_filter :filter_out_token, :only => [:verify, :unsubscribe]
  before_filter :force_ssl, :only => [:new]

  # NB: Devise calls User.new_with_session when building the new User resource.
  # We use this to apply any Provider based authentications to the user record.
  # This is trigged via Devise::RegistrationsController#build_resource

  # We extend the create action to clear out any stored Provider auth data used during
  # registration.
  before_filter :set_return_to, :only => [:new, :create]

  before_filter :authenticate_scope!, only: [:edit, :update, :destroy, :avatar, :edit_avatar, :update_avatar, :destroy_avatar, :set_password,
                                             :update_password, :edit_notification_preferences, :update_notification_preferences, :social_accounts]
  before_filter :find_supported_providers, :only => [:social_accounts, :update]
  after_filter :render_or_redirect_after_create, :only => [:create]
  before_filter :redirect_to_edit_profile_if_password_set, :only => [:set_password]

  skip_before_filter :redirect_if_marketplace_password_protected, :only => [:store_geolocated_location, :store_google_analytics_id, :update_password, :set_password]

  def new
    super unless already_signed_in?
  end

  def create
    begin
      super

      # Only track the sign up if the user has actually been saved (i.e. there are no errors)
      if @user.persisted?
        User.where(id: @user.id).update_all({referer: cookies.signed[:referer],
                                             source: cookies.signed[:source],
                                             campaign: cookies.signed[:campaign]})
        update_analytics_google_id(@user)
        analytics_apply_user(@user)
        event_tracker.signed_up(@user, {
          referrer_id: platform_context.platform_context_detail.id,
          referrer_type: platform_context.platform_context_detail.class.to_s,
          signed_up_via: signed_up_via,
          provider: Auth::Omni.new(session[:omniauth]).provider
        })
        PostActionMailer.enqueue_later(30.minutes).sign_up_welcome(@user)
        ReengagementNoBookingsJob.perform_later(72.hours.from_now, @user)
        PostActionMailer.enqueue.sign_up_verify(@user)
      end

      # Clear out temporarily stored Provider authentication data if present
      session[:omniauth] = nil unless @user.new_record?
      flash[:redirected_from_sign_up] = true
      @resource = resource
    rescue ActiveRecord::RecordNotUnique
      # we are trying to handle situation when user makes double request (button hit or page refresh)
      # request are handled by two server processes so AR validation goes fine, but DB throws exception
      # trying to login this user
      resource = User.find_for_database_authentication(:email => params[resource_name][:email])
      if resource && resource.valid_password?(params[resource_name][:password])
        @user = resource
        sign_in(resource_name, resource)
        redirect_to root_path
      end
    end
  end

  def edit
    @country = current_user.country_name
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
    super
  end

  def show
    @user = User.find(params[:id]).decorate
  end

  def update
    resource.country_name_required = true
    if resource.update_with_password(params[resource_name])
      set_flash_message :success, :updated
      sign_in(resource, :bypass => true)
      event_tracker.updated_profile_information(@user)
      redirect_to :action => 'edit'
    else
      @country = current_user.country_name
      render :edit
    end
  end

  def destroy
    raise ActionController::RoutingError, "Feature disabled"
  end

  def avatar
    @user = current_user
    @user.avatar_original_url = params[:avatar]
    if @user.save
      render :text => { :url => @user.avatar_url(:medium),
                        :resize_url =>  edit_avatar_path,
                        :thumbnail_dimensions => @user.avatar.thumbnail_dimensions[:medium],
                        :destroy_url => destroy_avatar_path }.to_json, :content_type => 'text/plain'
    else
      render :text => [{:error => @user.errors.full_messages}].to_json,:content_type => 'text/plain', :status => 422
    end
  end

  def edit_avatar
    if request.xhr?
      render partial: 'manage/photos/resize_form', :locals => { :form_url => update_avatar_path, :object => current_user.avatar, :object_url => current_user.avatar_url(:original) }
    end
  end

  def update_avatar
    @user = current_user
    @user.avatar_transformation_data = { :crop => params[:crop], :rotate => params[:rotate] }
    if @user.save
      render partial: 'manage/photos/resize_succeeded'
    else
      render partial: 'manage/photos/resize_form', :locals => { :form_url => update_avatar_path, :object => current_user.avatar, :object_url => current_user.avatar_url(:original) }
    end
  end

  def destroy_avatar
    @user = current_user
    @user.remove_avatar!
    @user.save!
    render :text => {}, :status => 200, :content_type => 'text/plain'
  end

  def set_password
    @user = current_user
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def update_password
    @user = current_user
    @user.password = params[:user][:password]
    @user.skip_password = false
    if @user.save
      flash[:success] = t('flash_messages.registrations.password_set')
      redirect_to edit_user_registration_path(:token => @user.authentication_token)
    else
      render :set_password
    end
  end

  def verify
    @user = User.find(params[:id])
    if @user.verify_email_with_token(params[:token])
      sign_in(@user)
      event_tracker.track_event_within_email(@user, request) if params[:track_email_event]
      flash[:success] = t('flash_messages.registrations.address_verified')
      redirect_to @user.listings.count > 0 ? manage_locations_path : edit_user_registration_path
    else
      if @user.verified_at
        flash[:warning] = t('flash_messages.registrations.address_already_verified')
      else
        flash[:error] = t('flash_messages.registrations.address_not_verified')
      end
      redirect_to root_path
    end
  end

  def store_google_analytics_id
    cookies[:google_analytics_id] = params[:id]
    update_analytics_google_id(current_user)
    render :nothing => true
  end

  def store_geolocated_location
    if user_signed_in? && params[:longitude] && params[:latitude]
      @user = current_user
      @user.last_geolocated_location_longitude = params[:longitude]
      @user.last_geolocated_location_latitude = params[:latitude]
      @user.save if @user.changes.present?
    end
    render :nothing => true
  end

  def unsubscribe
    if user_signed_in?
      verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
      begin
        mailer_name = verifier.verify(params[:signature])
        unless current_user.unsubscribed?(mailer_name)
          current_user.unsubscribe(mailer_name)
          PostActionMailer.enqueue.unsubscription(current_user, mailer_name)
          flash[:success] = t('flash_messages.registrations.unsubscribed_successfully')
        else
          flash[:warning] = t('flash_messages.registrations.already_unsubscribed')
        end
      rescue ActiveSupport::MessageVerifier::InvalidSignature
      end

      redirect_to root_path
    else
      session[:user_return_to] = request.path
      redirect_to new_user_session_path
    end
  end

  def social_accounts
  end

  def edit_notification_preferences
    @user = current_user
  end

  def update_notification_preferences
    @user = current_user
    params[:user][:sms_preferences] ||= {}
    if @user.update_with_password(params[:user])
      flash[:success] = t('flash_messages.registrations.notification_preferences_updated_successfully')
      redirect_to :action => 'edit_notification_preferences'
    else
      render :edit_notification_preferences
    end
  end

  protected

  def is_navigational_format?
    # Wizards don't get flash messages
    if params[:wizard]
      false
    else
      super
    end
  end

  def find_supported_providers
    @supported_providers = Authentication.available_providers
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end

  private

  def signed_up_via
    if !request.referrer.nil? && request.referrer.include?('return_to=%2Fspace%2Flist&wizard=space')
      'flow'
    else
      'other'
    end
  end

  # if ajax call has been made from modal and user has been created, we need to tell
  # Modal that instead of rendering content in modal, it needs to redirect to new page
  def render_or_redirect_after_create
    if request.xhr?
      if @user.persisted?
        render_redirect_url_as_json
      end
    end
  end

  def redirect_to_edit_profile_if_password_set
    if current_user
      redirect_to edit_user_registration_path unless set_password_necessary?
    else
      redirect_to new_user_session_path
    end
  end

end

