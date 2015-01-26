class Manage::BuySell::Products::ImagesController < Manage::BuySell::BaseController

  before_filter :find_product
  before_filter :find_image, only: [:edit, :update, :destroy]
  before_filter :find_variants, except: [:destroy, :index]

  def index
    @images = @product.variant_images.paginate(page: params[:page], per_page: 20)
  end

  def new
    @image = @product.images.new
  end

  def create
    @image = @product.images.new(image_params)
    set_viewable
    if @image.save
      redirect_to location_after_save, notice: t('flash_messages.manage.product_image.created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    set_viewable
    if @image.update_attributes(image_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.product_image.updated')
    else
      flash[:error] = t('flash_messages.menage.product_image.error_update')
      render :edit
    end
  end

  def destroy
    @image.destroy
    redirect_to location_after_save, notice: t('flash_messages.manage.product_image.deleted')
  end

  private

  def image_params
    params.require(:image).permit(secured_params.spree_image)
  end

  def find_variants
    @variants = @product.variants.collect do |variant|
      [variant.sku_and_options_text, variant.id]
    end
    @variants.insert(0, [Spree.t(:all), @product.master.id])
  end

  def find_image
    @image = @product.variant_images.find(params[:id])
  end

  def location_after_save
    manage_buy_sell_product_images_url(@product)
  end

  def set_viewable
    @image.viewable_type = 'Spree::Variant'
    @image.viewable_id = params[:image][:viewable_id]
  end
end
