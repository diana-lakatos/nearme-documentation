class Manage::BuySell::Products::VariantsController < Manage::BuySell::BaseController
  before_filter :find_product
  before_filter :find_variant, only: [:edit, :update, :destroy]
  before_filter :set_form_objects, only: [:new, :create, :update, :edit]

  def index
    @variants = @product.variants.paginate(page: params[:page], per_page: 20)
  end

  def new
    @variant = @product.variants.new()
  end

  def create
    @variant = @product.variants.new(variant_params)
    if @variant.save
      redirect_to location_after_save, notice: t('flash_messages.manage.variant.created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @variant.update_attributes(variant_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.variant.created')
    else
      render :edit
    end
  end

  def variant
    @prototype.destroy
    redirect_to location_after_save
  end

  private

  private

  def location_after_save
    manage_buy_sell_product_variants_url(@product)
  end

  def find_variant
    @variant = @product.variants.find(params[:id])
  end

  def set_form_objects
    @tax_categories = @company.tax_categories
  end

  def variant_params
    params.require(:variant).permit(secured_params.spree_variant)
  end

end
