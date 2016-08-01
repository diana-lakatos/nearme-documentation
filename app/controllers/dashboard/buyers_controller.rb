class Dashboard::BuyersController < Dashboard::BaseController

  before_filter :set_buyer_profile
  before_filter :set_form_components, only: [:edit, :update]

  def edit
  end

  def update
    current_user.assign_attributes(user_params)
    if current_user.save
      flash.now[:success] = t('flash_messages.dashboard.buyer.updated')
      if session[:after_onboarding_path].present?
        redirect_to session[:after_onboarding_path]
        session[:after_onboarding_path] = nil
      else
        render :edit
      end
    else
      flash.now[:error] = current_user.errors.full_messages.join("\n")
      render :edit
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

end
