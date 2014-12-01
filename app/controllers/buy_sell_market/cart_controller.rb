class BuySellMarket::CartController < ApplicationController
  before_filter :authenticate_user!

  before_filter :set_service, only: [:empty, :remove, :add, :update]
  before_filter :set_product, only: [:add]

  def index
    @cart = BuySell::CartDecorator.new(current_user)
  end

  def add
    @cart_service.add_product(@product)
    redirect_to cart_index_path, notice: 'Product added successfully' # TODO I18n
  end

  def remove
    @cart_service.remove_item(params[:item_id])
    redirect_to cart_index_path
  end

  def empty
    @cart_service.empty!
    redirect_to cart_index_path
  end

  def update
    @cart_service.update_qty_on_items(params[:quantity])
    redirect_to cart_index_path, notice: 'Cart successfully updated' # TODO I18n
  end

  private

  def set_service
    @cart_service = current_user.cart
  end

  def set_product
    @product = Spree::Product.searchable.friendly.find(params[:product_id])
  end
end
