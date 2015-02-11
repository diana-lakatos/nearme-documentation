class Dashboard::ShippingCategoriesController < Dashboard::BaseController

  skip_before_filter :redirect_unless_registration_completed, only: [:new, :create]

  def new
    @shipping_category_form = ShippingCategoryForm.new(Spree::ShippingCategory.new, @company)
    @shipping_category_form.assign_all_attributes
    render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_categories_path, :form_method => :post }
  end

  def create
    @company ||= Company.new
    @shipping_category = @company.shipping_categories.build
    @shipping_category.user_id = current_user.id
    @shipping_category_form = ShippingCategoryForm.new(@shipping_category, @company)
    if @shipping_category_form.submit(params[:shipping_category_form])
      render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_categories_path, :form_method => :post, :is_success => true }
    else
      render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_categories_path, :form_method => :post }
    end
  end

  def edit
    shipping_category = @company.shipping_categories.where(:id => params[:id]).first
    @shipping_category_form = ShippingCategoryForm.new(shipping_category, @company)
    @shipping_category_form.assign_all_attributes
    render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_category_path(shipping_category), :form_method => :put }
  end

  def update
    @shipping_category = @company.shipping_categories.find(params[:id])
    @shipping_category_form = ShippingCategoryForm.new(@shipping_category, @company)
    if @shipping_category_form.submit(params[:shipping_category_form])
      render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_categories_path, :form_method => :post, :is_success => true }
    else
      render :partial => 'shipping_category_form', :locals => { :form_url => dashboard_shipping_categories_path, :form_method => :post }
    end
  end

  private

  def shipping_category_form_params
    params.require(:shipping_category_form).permit(secured_params.shipping_category_form)
  end

end

