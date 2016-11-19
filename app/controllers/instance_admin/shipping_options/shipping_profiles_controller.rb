# frozen_string_literal: true
class InstanceAdmin::ShippingOptions::ShippingProfilesController < InstanceAdmin::ShippingOptions::BaseController
  before_action :set_breadcrumbs
  before_action :get_company

  def index
    @shipping_profiles = ShippingProfile.global
  end

  def new
    @shipping_profile = ShippingProfile.new
    render partial: 'dashboard/shipping_profiles/shipping_profile', locals: { form_url: instance_admin_shipping_options_shipping_profiles_path, form_method: :post }
  end

  def create
    @company ||= Company.new
    @shipping_profile = ShippingProfile.new(shipping_profile_params)
    @shipping_profile.user_id = current_user.id
    @shipping_profile.global = true
    if @shipping_profile.save
      render partial: 'dashboard/shipping_profiles/shipping_profile', locals: { form_url: instance_admin_shipping_options_shipping_profiles_path, form_method: :post, is_success: true }
    else
      render partial: 'dashboard/shipping_profiles/shipping_profile', locals: { form_url: instance_admin_shipping_options_shipping_profiles_path, form_method: :post }
    end
  end

  def edit
    @shipping_profile = ShippingProfile.find(params[:id])
    render partial: 'dashboard/shipping_profiles/shipping_profile', locals: { form_url: instance_admin_shipping_options_shipping_profile_path(@shipping_profile), form_method: :put }
  end

  def update
    @shipping_profile = ShippingProfile.find(params[:id])
    shipping_profile_params[:global] = true
    if @shipping_profile.update(shipping_profile_params)
      render partial: 'dashboard/shipping_profiles/shipping_profile', locals: { form_url: instance_admin_shipping_options_shipping_profiles_path, form_method: :post, is_success: true }
    else
      render partial: 'dashboard/shipping_profiles/shipping_profile', locals: { form_url: instance_admin_shipping_options_shipping_profiles_path, form_method: :post }
    end
  end

  def destroy
    @shipping_profile = ShippingProfile.global.find(params[:id])
    @shipping_profile.destroy
    redirect_to action: :index
  end

  def get_shipping_categories_list
    @shipping_profiles = ShippingProfile.global

    render partial: 'categories_list'
  end

  private

  def prepend_view_paths
    prepend_view_path InstanceViewResolver.instance
  end

  def get_company
    @company = Company.new
  end

  def set_breadcrumbs
    @breadcrumbs_title = 'Shipping Profiles'
  end

  def shipping_profile_params
    params.require(:shipping_profile).permit(secured_params.shipping_profile)
  end
end
