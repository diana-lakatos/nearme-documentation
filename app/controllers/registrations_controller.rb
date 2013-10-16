class RegistrationsController < Devise::RegistrationsController

  # NB: Devise calls User.new_with_session when building the new User resource.
  # We use this to apply any Provider based authentications to the user record.
  # This is trigged via Devise::RegistrationsController#build_resource

  # We extend the create action to clear out any stored Provider auth data used during
  # registration.
  before_filter :find_supported_providers, :only => [:edit, :update]
  before_filter :set_return_to, :only => [:new, :create]
  after_filter :render_or_redirect_after_create, :only => [:create]

  def new
    super unless already_signed_in?
  end

  def create
    super

    # Only track the sign up if the user has actually been saved (i.e. there are no errors)
    if @user.persisted?
      User.where(id: @user.id).update_all({referer: cookies.signed[:referer],
                                           source: cookies.signed[:source],
                                           campaign: cookies.signed[:campaign]})
      update_analytics_google_id(@user)
      analytics_apply_user(@user)
      event_tracker.signed_up(@user, { signed_up_via: signed_up_via, provider: Auth::Omni.new(session[:omniauth]).provider })
      AfterSignupMailer.enqueue_later(1.hour).help_offer(request_context, @user)
      UserMailer.enqueue.email_verification(request_context, @user)
    end

    # Clear out temporarily stored Provider authentication data if present
    session[:omniauth] = nil unless @user.new_record?
    flash[:redirected_from_sign_up] = true
    @resource = resource
  end

  def edit
    @country = current_user.country_name
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
      render partial: 'manage/photos/resize_form', :locals => { :form_url => update_avatar_path, :object => current_user.avatar, :object_url => current_user.avatar_url }
    end
  end

  def update_avatar
    @user = current_user
    @user.avatar_transformation_data = { :crop => params[:crop], :rotate => params[:rotate] }
    if @user.save
      render partial: 'manage/photos/resize_succeeded'
    else
      render partial: 'manage/photos/resize_form', :locals => { :form_url => update_avatar_path, :object => current_user.avatar, :object_url => current_user.avatar_url }
    end
  end

  def destroy_avatar
    @user = current_user
    @user.remove_avatar!
    @user.save!
    render :text => {}, :status => 200, :content_type => 'text/plain' 
  end

  def verify
    @user = User.find(params[:id])
    if @user.verify_email_with_token(params[:token])
      sign_in(@user)
      flash[:success] = t('registrations.address_verified')
      redirect_to @user.listings.count > 0 ? manage_locations_path : edit_user_registration_path
    else
      if @user.verified_at
        flash[:warning] = t('registrations.address_already_verified')
      else
        flash[:error] = t('registrations.address_not_verified')
      end
      redirect_to root_path
    end
  end

  def store_google_analytics_id
    cookies[:google_analytics_id] = params[:id]
    update_analytics_google_id(current_user)
    render :nothing => true
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

end

