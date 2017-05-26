# frozen_string_literal: true
class RegistrationsController < Devise::RegistrationsController
  skip_before_action :redirect_unverified_user, except: :show
  before_action :set_role_if_blank
  before_action :configure_permitted_parameters, only: :create
  skip_before_action :redirect_to_set_password_unless_unnecessary, only: [:update_password, :set_password]
  skip_before_action :filter_out_token, only: [:verify, :unsubscribe]
  skip_before_action :force_fill_in_wizard_form
  before_action :nm_force_ssl, only: [:new]
  before_action :find_company, only: [:social_accounts, :edit]
  before_action :set_form_components, only: [:edit, :update]
  before_action :redirect_from_default, only: [:edit, :update]
  before_action :find_user_or_redirect_to_slug, only: [:show]

  # NB: Devise calls User.new_with_session when building the new User resource.
  # We use this to apply any Provider based authentications to the user record.
  # This is trigged via Devise::RegistrationsController#build_resource

  # We extend the create action to clear out any stored Provider auth data used during
  # registration.
  before_action :set_return_to, only: [:new, :create]

  before_action :authenticate_scope!, only: [:edit, :update, :destroy, :avatar, :edit_avatar, :update_avatar, :destroy_avatar, :set_password,
                                             :update_password, :edit_notification_preferences, :update_notification_preferences, :social_accounts]
  before_action :find_supported_providers, only: [:social_accounts, :update]
  after_action :render_or_redirect_after_create, only: [:create]
  before_action :redirect_to_edit_profile_if_password_set, only: [:set_password]
  before_action :build_user_update_profile_form, only: [:edit, :update]

  skip_before_action :redirect_if_marketplace_password_protected, only: [:store_geolocated_location, :update_password, :set_password]

  def new
    @legal_page_present = Page.exists?(slug: 'legal')
    setup_form_component
    super unless already_signed_in?
  end

  def status
    render json: { id: current_user.try(:id), name: current_user.try(:name) }
  end

  def create
    params[:user][:custom_validation] = true
    setup_form_component
    params[:user][:force_profile] = @role
    begin
      super

      # Only track the sign up if the user has actually been saved (i.e. there are no errors)
      if @user.persisted?
        User.where(id: @user.id).update_all(instance_profile_type_id: current_instance.default_profile_type.try(:id),
                                            referer: session[:referer],
                                            source: cookies.signed[:source],
                                            campaign: cookies.signed[:campaign],
                                            language: I18n.locale)
        case @role
        when 'default'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::AccountCreated, @user.id, as: current_user)
        when 'seller'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::ListerAccountCreated, @user.id, as: current_user)
        when 'buyer'
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::EnquirerAccountCreated, @user.id, as: current_user)
        end
      end

      # Clear out temporarily stored Provider authentication data if present
      session[:omniauth] = nil unless @user.new_record?
      flash[:redirected_from_sign_up] = true
      @resource = resource
    rescue ActiveRecord::RecordNotUnique
      # we are trying to handle situation when user makes double request (button hit or page refresh)
      # request are handled by two server processes so AR validation goes fine, but DB throws exception
      # trying to login this user
      resource = User.find_for_database_authentication(email: params[resource_name][:email])
      if resource && resource.valid_password?(params[resource_name][:password])
        @user = resource
        sign_in(resource_name, resource)
        redirect_to root_path
      end
    end
  end

  def edit
    @country = current_user.country_name
    @user_update_profile_form.prepopulate!
    render :edit, layout: dashboard_or_community_layout
  end

  def show
    @theme_name = 'buy-sell-theme'

    if platform_context.instance.is_community?
      @projects = IntelFakerService.projects(4)

      @feed = ActivityFeedService.new(@user, user_feed: true, page: params[:page], current_user: current_user)
      @events = @feed.events
      @context_cache_key = current_instance.context_cache_key

      @transactables_followed = @user.feed_followed_transactables.active.paginate(pagination_params)
      @topics_followed = @user.feed_followed_topics.paginate(pagination_params)
      @users_followed = @user.feed_followed_users.paginate(pagination_params)
      @followers = @user.feed_followers.paginate(pagination_params)
      @all_transactables = @user.all_transactables(current_user == @user).active.paginate(pagination_params)
      @groups = @user.all_group_collaborated.paginate(pagination_params).decorate
    else
      @company = @user.companies.first
      if @company.present?
        @listings = @company.listings.searchable.includes(:location).paginate(page: params[:services_page], per_page: 8)
      end

      @reviews_counter = ReviewAggregator.new(@user) if RatingSystem.active.any?
    end
    respond_to :html
  end

  def update
    if @user_update_profile_form.validate(params[:form].presence || params[:user] || {})
      @user_update_profile_form.save
      I18n.locale = current_user.reload.language&.to_sym || :en
      onboarded = current_user.buyer_profile.try(:mark_as_onboarded!) || current_user.seller_profile.try(:mark_as_onboarded!)
      set_flash_message :success, :updated
      sign_in(resource, bypass: true)
      redirect_to dashboard_profile_path(onboarded: onboarded)
    else
      @user_update_profile_form.prepopulate!
      flash.now[:error] = @user_update_profile_form.pretty_errors_string
      render :edit, layout: dashboard_or_community_layout
    end
  end

  def destroy
    raise ActionController::RoutingError, 'Feature disabled'
  end

  def avatar
    @user = current_user
    @user.avatar = params[:avatar]
    if @user.save(validate: false)
      render text: { url: @user.avatar_url(:medium),
                     resize_url: edit_avatar_path,
                     thumbnail_dimensions: @user.avatar.thumbnail_dimensions[:medium],
                     destroy_url: destroy_avatar_path }.to_json, content_type: 'text/plain'
    else
      render text: [{ error: @user.errors.full_messages }].to_json, content_type: 'text/plain', status: 422
    end
  end

  def edit_avatar
    if request.xhr?
      render partial: 'dashboard/photos/resize_form', locals: { form_url: update_avatar_path, object: current_user.avatar, object_url: current_user.avatar.url }
    end
  end

  def update_avatar
    @user = current_user
    @user.avatar_transformation_data = { crop: params[:crop], rotate: params[:rotate] }
    if @user.save(validate: false)
      render partial: 'dashboard/photos/resize_succeeded'
    else
      edit_avatar
    end
  end

  def destroy_avatar
    @user = current_user
    @user.remove_avatar!
    @user.save(validate: false)
    render text: {}, status: 200, content_type: 'text/plain'
  end

  def cover_image
    @user = current_user
    @user.cover_image = params[:cover_image]
    if @user.save(validate: false)
      render text: { url: @user.cover_image_url,
                     resize_url: edit_cover_image_path,
                     thumbnail_dimensions: @user.cover_image.thumbnail_dimensions[:thumbnail],
                     destroy_url: destroy_cover_image_path }.to_json, content_type: 'text/plain'
    else
      render text: [{ error: @user.errors.full_messages }].to_json, content_type: 'text/plain', status: 422
    end
  end

  def edit_cover_image
    if request.xhr?
      render partial: 'dashboard/photos/resize_form', locals: { form_url: update_cover_image_path, object: current_user.cover_image, object_url: current_user.cover_image.url }
    end
  end

  def update_cover_image
    @user = current_user
    @user.cover_image_transformation_data = { crop: params[:crop], rotate: params[:rotate] }
    if @user.save(validate: false)
      render partial: 'dashboard/photos/resize_succeeded'
    else
      edit_cover_image
    end
  end

  def destroy_cover_image
    @user = current_user
    @user.remove_cover_image!
    @user.save(validate: false)
    render text: {}, status: 200, content_type: 'text/plain'
  end

  def set_password
    @user = current_user
  end

  def update_password
    @user = current_user
    @user.password = params[:user][:password]
    if @user.save
      flash[:success] = t('flash_messages.registrations.password_set')
      redirect_to edit_user_registration_path(token: @user.authentication_token)
    else
      flash[:success] = @user.errors.full_messages.join(', ')
      render :set_password
    end
  end

  def verify
    @user = User.find(params[:id])
    @verification_form = UserVerificationForm.new(@user, verified_at: @user.verified_at)
    if @verification_form.validate(params)
      @verification_form.save
      sign_in(@user)
      flash[:success] = t('flash_messages.registrations.address_verified')
      redirect_to @user.listings.count > 0 ? dashboard_path : edit_user_registration_path
    else
      if @user.verified_at
        flash[:warning] = t('flash_messages.registrations.address_already_verified')
      else
        flash[:error] = t('flash_messages.registrations.address_not_verified')
      end
      redirect_to root_path
    end
  end

  def unsubscribe
    if user_signed_in?
      verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
      begin
        mailer_name = verifier.verify(params[:signature])
        if current_user.unsubscribed?(mailer_name)
          flash[:warning] = t('flash_messages.registrations.already_unsubscribed')
        else
          current_user.unsubscribe(mailer_name)
          flash[:success] = t('flash_messages.registrations.unsubscribed_successfully')
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
    cookies[:redirect_after_callback_to] = { value: request.path, expires: 1.hour.from_now }
    render layout: dashboard_or_community_layout
  end

  def edit_notification_preferences
    @user = current_user
  end

  def update_notification_preferences
    @user = current_user
    params[:user][:sms_preferences] ||= {}
    if @user.update_with_password(user_params)
      flash[:success] = t('flash_messages.registrations.notification_preferences_updated_successfully')
      redirect_to action: 'edit_notification_preferences'
    else
      render :edit_notification_preferences
    end
  end

  def mobile_number
    current_user.update user_params

    @country = current_user.country_name
    @return_path = params[:return_path]

    # We only want to render the missing phone number if there's an actual error
    # for the mobile number, like missing for example
    if current_user.invalid? && current_user.errors[:mobile_number].present?
      render('dashboard/user_messages/missing_phone_number')
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
    # We can't prevent Devise from setting return_to to users/sign_in on unsuccessful sign in
    # so we then prevent saving it if present
    disallowed_regex = /(users\/sign_in|users\/password)/
    if params[:return_to].present? && !params[:return_to].to_s.match(disallowed_regex)
      session[:user_return_to] = params[:return_to]
    end
  end

  private

  def find_company
    @company = current_user.try(:companies).try(:first)
  end

  def set_form_components
    @form_components = current_instance.default_profile_type.form_components.where(form_type: FormComponent::INSTANCE_PROFILE_TYPES).rank(:rank)
  end

  def signed_up_via
    if !request.referer.nil? && request.referer.include?('return_to=%2Fspace%2Flist&wizard=space')
      'flow'
    else
      'other'
    end
  end

  # if ajax call has been made from modal and user has been created, we need to tell
  # Modal that instead of rendering content in modal, it needs to redirect to new page
  def render_or_redirect_after_create
    render_redirect_url_as_json if request.xhr? && @user.persisted?
  end

  def redirect_to_edit_profile_if_password_set
    if current_user
      redirect_to edit_user_registration_path unless set_password_necessary?
    else
      redirect_to new_user_session_path
    end
  end

  protected

  def configure_permitted_parameters
    arguments = [:name, :email, :accept_terms_of_service, :password, :password_confirmation, :custom_validation, :force_profile]
    arguments += case params[:role]
                 when 'buyer'
                   secured_params.user
                 when 'seller'
                   secured_params.user
                 when 'default'
                   secured_params.user
                 else
                   []
                 end
    devise_parameter_sanitizer.permit(:sign_up, keys: [arguments])
  end

  def user_params
    params.require(:user).permit(secured_params.user).tap do |whitelisted|
      whitelisted[:sms_preferences] = params[:user][:sms_preferences] if params[:user][:sms_preferences]
      whitelisted[:properties] = params[:user][:properties] if params[:user][:properties]
    end
  end

  def pagination_params
    {
      page: 1,
      per_page: ActivityFeedService::Helpers::FOLLOWED_PER_PAGE
    }
  end

  def set_role_if_blank
    params[:role] ||= 'buyer' if current_instance.split_registration?
  end

  def setup_form_component
    @role = %w(seller buyer).detect { |r| r == params[:role] }
    @role ||= 'default'
    @form_component = FormComponent.find_by(form_type: "FormComponent::#{@role.upcase}_REGISTRATION".constantize)
  end

  def redirect_from_default
    return if current_user&.has_default_profile?
    return redirect_to(edit_dashboard_seller_path) if current_user&.has_seller_profile?
    return redirect_to(edit_dashboard_buyer_path) if current_user&.has_buyer_profile?
  end

  def find_user_or_redirect_to_slug
    @user = if current_user.try(:admin?)
              User.find(params[:id])
            else
              User.not_admin.find(params[:id])
            end

    if @user.id.to_s == params[:id] && @user.slug.present? && @user.slug != @user.id.to_s
      redirect_to profile_url(@user.slug), status: 301
    end
  end

  def build_user_update_profile_form
    @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id])
    @user_update_profile_form = @form_configuration&.build(current_user)
    return true if @user_update_profile_form.present?
    @user_update_profile_form = if current_user.buyer_profile.present? && current_user.seller_profile.blank?
                                  FormConfiguration.where(base_form: 'UserUpdateProfileForm', name: 'enquirer_update')
                                elsif current_user.seller_profile.present? && current_user.buyer_profile.blank?
                                  FormConfiguration.where(base_form: 'UserUpdateProfileForm', name: 'lister_update')
                                else
                                  FormConfiguration.where(base_form: 'UserUpdateProfileForm', name: 'default_update')
                                end.first.build(current_user)
  end
end
