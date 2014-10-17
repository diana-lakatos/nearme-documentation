class BuySell::OrdersController < ApplicationController
  skip_before_filter :redirect_if_marketplace_password_protected

  before_filter :authenticate_user!

  def index
    @orders = current_user.orders
    @orders = params[:state] == 'complete' ? @orders.complete : @orders.incomplete
  end
end
