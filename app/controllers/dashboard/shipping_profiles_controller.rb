class Dashboard::ShippingProfilesController < Dashboard::BaseController
  skip_before_filter :redirect_unless_registration_completed, only: [:new, :create]

  def new
    @shipping_profile = ShippingProfile.new
    render partial: 'shipping_profile', locals: { form_url: dashboard_shipping_profiles_path, form_method: :post }
  end

  def create
    @company ||= Company.new
    @shipping_profile = @company.shipping_profiles.build(shipping_profile_params)
    @shipping_profile.user_id = current_user.id
    if @shipping_profile.save
      render partial: 'shipping_profile', locals: { form_url: dashboard_shipping_profiles_path, form_method: :post, is_success: true }
    else
      render partial: 'shipping_profile', locals: { form_url: dashboard_shipping_profiles_path, form_method: :post }
    end
  end

  def edit
    @shipping_profile = ShippingProfile.find(params[:id])
    render partial: 'shipping_profile', locals: { form_url: dashboard_shipping_profile_path(@shipping_profile), form_method: :put }
  end

  def update
    shipping_profile = ShippingProfile.find(params[:id])
    if shipping_profile.global?
      @shipping_profile = shipping_profile.dup
      @shipping_profile.company = @company
      @shipping_profile.user = current_user
      @shipping_profile.global = false
      @shipping_profile.save
      profile_params = shipping_profile_params
      if profile_params[:name] == @shipping_profile.name
        @shipping_profile.name += I18n.t('general.customized')
        profile_params.delete :name
      end
      profile_params['shipping_rules_attributes'].each { |_k, values| values.delete('id') }
    else
      @shipping_profile = shipping_profile
      profile_params = shipping_profile_params
    end
    if @shipping_profile.update(profile_params)
      render partial: 'shipping_profile', locals: { form_url: dashboard_shipping_profile_path(@shipping_profile), form_method: :put, is_success: true }
    else
      render partial: 'shipping_profile', locals: { form_url: dashboard_shipping_profile_path(@shipping_profile), form_method: :put }
    end
  end

  def destroy
    @shipping_profile = current_user.shipping_profiles.find(params[:id])
    @shipping_profile.destroy
  end

  def get_shipping_profiles_list
    @company ||= Company.new
    @transactable = @company.listings.build

    render partial: 'shipping_profiles_list_form_products'
  end
  #

  private

  def shipping_profile_params
    params.require(:shipping_profile).permit(secured_params.shipping_profile)
  end
end
