class Dashboard::BuyersController < Dashboard::BaseController
  before_filter :set_buyer_profile
  before_filter :set_form_components, only: [:edit, :update]
  skip_before_filter :force_fill_in_wizard_form
  before_action :build_user_update_profile_form, only: [:edit, :update]

  def edit
    @user_update_profile_form.prepopulate!
  end

  def update
    if @user_update_profile_form.validate(params[:user] || params[:form] || {})
      @user_update_profile_form.save
      current_user.reload.buyer_profile.mark_as_onboarded!
      flash.now[:success] = t('flash_messages.dashboard.buyer.updated')
      if session[:after_onboarding_path].present?
        redirect_to session[:after_onboarding_path]
        session[:after_onboarding_path] = nil
      else
        redirect_to edit_dashboard_buyer_path
      end
    else
      flash.now[:error] = @user_update_profile_form.pretty_errors_string
      @user_update_profile_form.prepopulate!
      render :edit, layout: dashboard_or_community_layout
    end
  end

  protected

  def set_buyer_profile
    @buyer_profile = current_user.buyer_profile
    redirect_to edit_registration_path(current_user) unless @buyer_profile.present? && current_instance.buyer_profile_enabled?
  end

  def set_form_components
    @form_components = PlatformContext.current.instance.buyer_profile_type.form_components.where(form_type: FormComponent::BUYER_PROFILE_TYPES).rank(:rank)
  end

  def user_params
    params.require(:user).permit(secured_params.user)
  end

  def build_user_update_profile_form
    @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id])
    @user_update_profile_form = @form_configuration&.build(current_user) || FormConfiguration.where(base_form: 'UserUpdateProfileForm', name: 'Enquirer Update').first.build(current_user)
  end
end
