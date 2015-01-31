class Dashboard::Company::PaymentsController < Dashboard::Company::BaseController
  def capture
    @order = @company.orders.find_by_number(params[:orders_received_id])
    @payment = @order.payments.find(params[:id])

    charge = @order.near_me_payments.create!(
      subtotal_amount: @order.total_amount_without_fee,
      service_fee_amount_guest: @order.service_fee_amount_guest,
      service_fee_amount_host: @order.service_fee_amount_host
    )

    if charge.paid?
      @payment.complete! unless @payment.state == 'completed'
    else
      @payment.failure!
    end

    redirect_to dashboard_company_orders_received_path(@order)
  end
end
