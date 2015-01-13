class Dashboard::ProductsController < Dashboard::BaseController
  before_filter :find_product, only: [:edit, :update, :destroy]

  def index
    @products = @company.products.paginate(page: params[:page], per_page: 20)
  end

  def new
    @product = @company.products.build user: current_user
    @product_form = ProductForm.new(@product)
    @product_form.assign_all_attributes
    @images = current_user.products_images.where(viewable_id: nil, viewable_type: nil)
  end

  def create
    @product = @company.products.build user: current_user
    @product_form = ProductForm.new(@product)
    if @product_form.submit(product_form_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.product.created')
    else
      flash.now[:error] = t('flash_messages.product.complete_fields')
      render :new
    end
  end

  def edit
    @product_form = ProductForm.new(@product)
    @product_form.assign_all_attributes
    @images = @product_form.product.images
  end

  def update
    @product_form = ProductForm.new(@product)
    if @product_form.submit(product_form_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.product.updated')
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to dashboard_products_url
  end

  private

  def location_after_save
    dashboard_products_path
  end

  def find_product
    @product = @company.products.with_deleted.friendly.find(params[:product_id] || params[:id])
  end

  def product_form_params
    params.require(:product_form).permit(secured_params.product_form)
  end
end
