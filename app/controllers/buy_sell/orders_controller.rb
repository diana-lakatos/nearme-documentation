class BuySell::OrdersController < ApplicationController
  skip_before_filter :redirect_if_marketplace_password_protected

  before_filter :authenticate_user!

  layout 'buy_sell'

  def index
    @orders = current_user.orders.complete.paginate(page: params[:page]).order('created_at DESC').decorate
    @theme_name = 'orders-theme'
  end

  def show
    @order = current_user.orders.find_by_number(params[:id])
    @theme_name = 'checkout-theme'
    render 'buy_sell_market/checkout/complete'
  end
end
