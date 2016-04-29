class Dashboard::SellersController < Dashboard::BaseController

  before_filter :set_seller_profile
  before_filter :set_form_components, only: [:edit, :update]

  def edit
  end

  def update
    current_user.assign_attributes(user_params)
    if current_user.save
      flash.now[:success] = t('flash_messages.dashboard.seller.updated')
    else
      flash.now[:error] = current_user.errors.full_messages.join("\n")
    end
    render :edit
  end

  protected

  def set_seller_profile
    @seller_profile = current_user.seller_profile
    redirect_to edit_registration_path(current_user) unless @seller_profile.present? && current_instance.seller_profile_enabled?
  end

  def set_form_components
    @form_components = PlatformContext.current.instance.seller_profile_type.form_components.where(form_type: FormComponent::SELLER_PROFILE_TYPES).rank(:rank)
  end

  def user_params
    params.require(:user).permit(secured_params.user)
  end

end
