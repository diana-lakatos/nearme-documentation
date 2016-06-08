class Dashboard::Company::ProductsController < Dashboard::Company::BaseController

  include AttachmentsHelper

  before_filter :find_product_type
  before_filter :find_product, only: [:edit, :update, :destroy]
  before_filter :set_form_components

  skip_before_filter :redirect_if_no_company, only: [:get_shipping_categories_list]

  skip_before_filter :redirect_unless_registration_completed, only: [:get_shipping_categories_list]

  before_filter :ensure_system_shipping_categories_copied, only: [:new, :edit]

  def index
    @products = @company.products.of_type(@product_type).
      search_by_query([:name, :description, :extra_properties], params[:query]).
        paginate(page: params[:page], per_page: 20)
  end

  def new
    @product = @company.products.build(user: current_user, product_type: @product_type)
    @product_form = ProductForm.new(@product)
    @product_form.assign_all_attributes
    @images = current_user.products_images.where(viewable_id: nil, viewable_type: nil)
    @attachments = current_user.attachments.where(assetable_id: nil)
  end

  def create
    @product = @company.products.build(user: current_user, product_type: @product_type)
    @product_form = ProductForm.new(@product)
    @product_form.product.attachment_ids = attachment_ids_for(@product_form.product)
    if @product_form.submit(product_form_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.product.created')
    else
      @images = @product_form.product.images
      @attachments = current_user.attachments.where(assetable_id: nil)
      render :new
    end
  end

  def edit
    @product_form = ProductForm.new(@product)
    @product_form.assign_all_attributes
    @images = @product_form.product.images
    @attachments = @product_form.product.attachments
  end

  def update
    return_to = params[:return_to].presence || location_after_save
    @product_form = ProductForm.new(@product)
    @product_form.product.attachment_ids = attachment_ids_for(@product_form.product)
    if @product_form.submit(product_form_params)
      redirect_to return_to, notice: t('flash_messages.manage.product.updated')
    else
      @images = @product_form.product.images.uniq
      @attachments = current_user.attachments.where(assetable_id: nil)
      flash.now[:error] = t('flash_messages.product.complete_fields')
      flash.now[:error] = t('flash_messages.product.missing_fields_invalid') if @product_form.required_field_missing?
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to location_after_save
  end

  private

  def ensure_system_shipping_categories_copied
    ShippingProfileableService.new(@company, current_user).clone!
  end

  def find_product_type
    @product_type = params[:product_type_id].present? ? Spree::ProductType.find(params[:product_type_id]) : Spree::ProductType.first
  end

  def set_form_components
    @form_components = @product_type.form_components.where(form_type: FormComponent::PRODUCT_ATTRIBUTES).rank(:rank)
  end

  def location_after_save
    dashboard_company_product_type_products_path(@product_type)
  end

  def find_product
    @product = @company.products.with_deleted.friendly.find(params[:product_id] || params[:id])
  end

  def product_form_params
    params.require(:product_form).permit(secured_params.product_form(@product_type))
  end
end
