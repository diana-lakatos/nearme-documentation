class InstanceAdmin::ShippingOptions::ShippingProfilesController < InstanceAdmin::ShippingOptions::BaseController

  before_filter :set_breadcrumbs

  before_filter :get_company

  def index
    @shipping_categories = Spree::ShippingCategory.system_profiles
  end

  def new
    @shipping_category_form = ShippingCategoryForm.new(Spree::ShippingCategory.new)
    @shipping_category_form.assign_all_attributes
    render :partial => 'dashboard/shipping_categories/shipping_category_form', :locals => { :form_url => instance_admin_shipping_options_shipping_profiles_path, :form_method => :post }
  end

  def create
    @shipping_category = @company.shipping_categories.build
    @shipping_category.user_id = current_user.id
    @shipping_category_form = ShippingCategoryForm.new(@shipping_category, is_system_profile: true)
    if @shipping_category_form.submit(shipping_category_form_params)
      render :partial => 'dashboard/shipping_categories/shipping_category_form', :locals => { :form_url => instance_admin_shipping_options_shipping_profiles_path, :form_method => :post, :is_success => true }
    else
      render :partial => 'dashboard/shipping_categories/shipping_category_form', :locals => { :form_url => instance_admin_shipping_options_shipping_profiles_path, :form_method => :post }
    end
  end

  def edit
    shipping_category = Spree::ShippingCategory.system_profiles.find(params[:id])

    @shipping_category_form = ShippingCategoryForm.new(shipping_category)
    @shipping_category_form.assign_all_attributes
    render :partial => 'dashboard/shipping_categories/shipping_category_form', :locals => { :form_url => instance_admin_shipping_options_shipping_profile_path(shipping_category), :form_method => :put }
  end

  def update
    @shipping_category = Spree::ShippingCategory.system_profiles.find(params[:id])

    @shipping_category_form = ShippingCategoryForm.new(@shipping_category, is_system_profile: true)
    if @shipping_category_form.submit(shipping_category_form_params)
      render :partial => 'dashboard/shipping_categories/shipping_category_form', :locals => { :form_url => instance_admin_shipping_options_shipping_profiles_path, :form_method => :post, :is_success => true }
    else
      render :partial => 'dashboard/shipping_categories/shipping_category_form', :locals => { :form_url => instance_admin_shipping_options_shipping_profiles_path, :form_method => :post }
    end
  end

  def destroy
    @shipping_category = Spree::ShippingCategory.system_profiles.find(params[:id])
    @shipping_category.destroy
    if request.xhr?
      render json: { success: true }
    else
      redirect_to instance_admin_shipping_options_shipping_profiles_path
    end
  end

  def get_shipping_categories_list
    shipping_categories = Spree::ShippingCategory.system_profiles

    render partial: "categories_list", locals: { shipping_categories: shipping_categories }
  end

  def disable_category
    shipping_category = Spree::ShippingCategory.system_profiles.find(params[:id])
    shipping_category.update_attributes(is_system_category_enabled: false)

    redirect_to instance_admin_shipping_options_shipping_profiles_path
  end

  def enable_category
    shipping_category = Spree::ShippingCategory.system_profiles.find(params[:id])
    shipping_category.update_attributes(is_system_category_enabled: true)

    redirect_to instance_admin_shipping_options_shipping_profiles_path
  end

  private

  def prepend_view_paths
    prepend_view_path InstanceViewResolver.instance
  end

  def get_company
    @company = current_user.companies.first || Company.new
  end

  def set_breadcrumbs
    @breadcrumbs_title = 'Shipping Profiles'
  end

  def shipping_category_form_params
    params.require(:shipping_category_form).permit(secured_params.shipping_category_form)
  end

end

