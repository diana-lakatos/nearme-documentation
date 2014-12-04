class Manage::BuySell::PaymentsController < Manage::BuySell::BaseController
  def capture
    @order = @company.orders.find_by_number(params[:order_id])
    @payment = @order.payments.find(params[:id])

    charge = @order.near_me_payments.create!(
      subtotal_amount: @order.total_amount_without_fee,
      service_fee_amount_guest: @order.service_fee_amount_guest,
      service_fee_amount_host: @order.service_fee_amount_host
    )
    if charge.paid?
      @payment.complete!
    else
      @payment.failure!
    end

    redirect_to :back
  end
end
