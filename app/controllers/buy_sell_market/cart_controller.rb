class BuySellMarket::CartController < ApplicationController
  before_filter :authenticate_user!

  before_filter :set_service, only: [:empty, :remove, :add, :update]
  before_filter :set_product, only: [:add]

  def index
    @cart = CartDecorator.new(current_user)
  end

  def add
    if @cart_service.add_product(@product)
      flash[:notice] = t('buy_sell_market.cart.notices.add')
    else
      flash[:error] = cart_errors
    end

    redirect_to cart_index_path
  end

  def update
    if @cart_service.update_qty_on_items(params[:quantity])
      flash[:notice] = t('buy_sell_market.cart.notices.update')
    else
      flash[:error] = cart_errors
    end

    redirect_to cart_index_path
  end

  def remove
    if @cart_service.remove_item(params[:item_id])
      flash[:notice] = t('buy_sell_market.cart.notices.remove')
    else
      flash[:error] = cart_errors
    end

    redirect_to cart_index_path
  end

  def empty
    @cart_service.empty!
    redirect_to cart_index_path, notice: t('buy_sell_market.cart.notices.empty')
  end

  private

  def cart_errors
    @cart_service.errors.join('\n')
  end

  def set_service
    @cart_service = current_user.cart
  end

  def set_product
    @product = Spree::Product.searchable.friendly.find(params[:product_id])
  end
end
