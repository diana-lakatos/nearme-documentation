class ExpressCheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :find_payment

  def return
    payment_source = @order.payment.payment_source
    payment_source.express_payer_id = params[:PayerID]
    payment_source.response = @order.payment.payment_gateway.gateway.details_for(@order.payment.express_token).params.to_yaml

    if @order.process!
      flash[:notice] = t('flash_messages.reservations.reservation_made', message: '')
      redirect_to dashboard_order_path(@order)
    else
      redirect_to order_checkout_path(@order)
    end
  end

  def cancel
    if @payment.authorized? || @payment.paid?
      redirect_to dashboard_order_path(@payment.payable)
    else
      flash[:error] = t('flash_messages.reservations.payment_failed')
      @payment.destroy

      redirect_to order_checkout_path(@order)
    end
  end

  private

  def find_payment
    @order = current_user.orders.cart.find(params[:order_id])
    @payment = @order.payment
  end
end
