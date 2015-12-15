class Dashboard::BuyersController < Dashboard::BaseController

  before_filter :set_buyer_profile
  before_filter :set_form_components, only: [:edit, :update]

  def edit
  end

  def update
    @buyer_profile.assign_attributes(buyer_profile_params)
    if @buyer_profile.save
      flash.now[:success] = t('flash_messages.dashboard.buyer.updated')
    else
      flash.now[:error] = @buyer_profile.errors.full_messages.join("\n")
    end
    render :edit
  end

  protected

  def set_buyer_profile
    @buyer_profile = current_user.buyer_profile
    redirect_to edit_registration_path(current_user) unless @buyer_profile.present? && current_instance.buyer_profile_enabled?
  end

  def set_form_components
    @form_components = PlatformContext.current.instance.buyer_profile_type.form_components.where(form_type: FormComponent::BUYER_PROFILE_TYPES).rank(:rank)
  end

  def buyer_profile_params
    params.require(:buyer_profile).permit(secured_params.user).tap do |whitelisted|
      whitelisted[:properties] = params[:buyer_profile][:properties] if params[:buyer_profile][:properties]
    end
  end

end
