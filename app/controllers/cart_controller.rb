class CartController < ApplicationController
  skip_before_filter :log_out_if_token_exists
  skip_before_filter :filter_out_token

  before_filter :authenticate_user!
  before_filter :set_service, only: [:empty, :remove, :add, :update]

  def index
    @cart = CartDecorator.new(current_user)
    @theme_name = 'buy-sell-theme'
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

  def clear_all
    order = current_user.orders.find(params[:order_id])
    if order
      order.destroy
      flash[:notice] = t('buy_sell_market.cart.notices.clear_all', company_name: order.company.name)
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
end
