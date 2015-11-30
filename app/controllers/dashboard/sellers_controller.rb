class Dashboard::SellersController < Dashboard::BaseController

  before_filter :set_seller_profile
  before_filter :set_form_components, only: [:edit, :update]

  def edit
  end

  def update
    @seller_profile.assign_attributes(seller_profile_params)
    if @seller_profile.save
      flash.now[:success] = t('flash_messages.dashboard.seller.updated')
    else
      flash.now[:error] = @seller_profile.errors.full_messages.join("\n")
    end
    render :edit
  end

  protected

  def set_seller_profile
    @seller_profile = current_user.seller_profile
    redirect_to edit_registration_path(current_user) unless @seller_profile.present?
  end

  def set_form_components
    @form_components = PlatformContext.current.instance.seller_profile_type.form_components.where(form_type: FormComponent::SELLER_PROFILE_TYPES).rank(:rank)
  end

  def seller_profile_params
    params.require(:seller_profile).permit(secured_params.user).tap do |whitelisted|
      whitelisted[:properties] = params[:seller_profile][:properties] if params[:seller_profile][:properties]
    end
  end

end
