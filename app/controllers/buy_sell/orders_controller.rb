class BuySell::OrdersController < ApplicationController
  skip_before_filter :redirect_if_marketplace_password_protected

  before_filter :authenticate_user!

  def index
    @orders = current_user.orders.complete
    # @orders = params[:state] == 'complete' ? @orders.complete : @orders.incomplete
  end

  def show
    @order = current_user.orders.find_by_number(params[:id])
  end
end
