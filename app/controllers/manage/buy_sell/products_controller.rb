class Manage::BuySell::ProductsController < Manage::BuySell::BaseController
  before_filter :find_product, only: [:edit, :update, :destroy]
  before_filter :load_data, only: [:edit, :update, :new, :create]

  def index
    @products = @company.products.paginate(page: params[:page], per_page: 20)
  end

  def new
    @product = @company.products.new()
  end

  def create
    @product = @company.products.new(product_params)
    if @product.save
      redirect_to location_after_save, notice: t('flash_messages.manage.product.created')
    else
      flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@product.errors.full_messages)
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update_attributes(product_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.product.updated')
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to manage_buy_sell_products_url
  end

  private

  def product_params
    params.require(:product).permit(secured_params.spree_product)
  end

  def load_data
    @option_types = @company.option_types.order(:name)
    @prototypes = @company.prototypes.order(:name)
    @taxons = Spree::Taxonomy.order(:name)
    @tax_categories = @company.tax_categories.order(:name)
    @shipping_categories = @company.shipping_categories.order(:name)
  end
end
