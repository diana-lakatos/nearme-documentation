class ExpressCheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :find_payment

  def return
    @payment.express_payer_id = params[:PayerID]
    reservation = @payment.payable
    if @payment.authorize && reservation.reload.save
      flash[:notice] = t('flash_messages.reservations.reservation_made', message: '')

      event_tracker.updated_profile_information(reservation.owner)
      event_tracker.updated_profile_information(reservation.host)
      event_tracker.requested_a_booking(reservation)

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
      @order = @payment.payable
      @payment.destroy

      redirect_to order_checkout_path(@order)
    end
  end

  private

  def find_payment
    @order = current_user.orders.find(params[:order_id])
    @payment = Payment.where(payable_id: @order.id, payable_type: @order.class.name).find_by!(express_token: params[:token])
  end
end
