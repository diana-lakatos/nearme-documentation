class Manage::BuySell::ProductsController < Manage::BuySell::BaseController
  before_filter :find_product, only: [:edit, :update, :destroy]

  def index
    @products = @company.products.paginate(page: params[:page], per_page: 20)
    @theme_name = 'product-theme'
  end

  def new
    @product = @company.products.build user: current_user
    @product_form = ProductForm.new(@product)
    @product_form.assign_all_attributes
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
    redirect_to manage_buy_sell_products_url
  end

  def product_form_params
    params.require(:product_form).permit(secured_params.product_form)
  end
end
