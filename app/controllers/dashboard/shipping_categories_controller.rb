class Dashboard::ShippingCategoriesController < Dashboard::BaseController

  skip_before_filter :redirect_unless_registration_completed, only: [:new, :create]

  def new
    @shipping_category_form = ShippingCategoryForm.new(Spree::ShippingCategory.new)
    @shipping_category_form.assign_all_attributes
    render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_categories_path, :form_method => :post }
  end

  def create
    @company ||= Company.new
    @shipping_category = @company.shipping_categories.build
    @shipping_category.user_id = current_user.id
    @shipping_category_form = ShippingCategoryForm.new(@shipping_category)
    if @shipping_category_form.submit(shipping_category_form_params)
      render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_categories_path, :form_method => :post, :is_success => true }
    else
      render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_categories_path, :form_method => :post }
    end
  end

  def edit
    shipping_category = @company.shipping_categories.where(:id => params[:id]).first
    @shipping_category_form = ShippingCategoryForm.new(shipping_category)
    @shipping_category_form.assign_all_attributes
    render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_category_path(shipping_category), :form_method => :put }
  end

  def update
    @shipping_category = @company.shipping_categories.find(params[:id])
    @shipping_category_form = ShippingCategoryForm.new(@shipping_category)
    if @shipping_category_form.submit(shipping_category_form_params)
      render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_category_path(@shipping_category), :form_method => :put, :is_success => true }
    else
      render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_category_path(@shipping_category), :form_method => :put }
    end
  end

  def get_shipping_categories_list
    @company ||= Company.new
    @product = @company.products.build user: current_user
    @product_form = ProductForm.new(@product)

    if params['form'] == 'boarding'
      render :partial => "shipping_profiles_list_form_boarding"
    else
      render :partial => "shipping_profiles_list_form_products"
    end
  end

  private

  def shipping_category_form_params
    params.require(:shipping_category_form).permit(secured_params.shipping_category_form)
  end

end

