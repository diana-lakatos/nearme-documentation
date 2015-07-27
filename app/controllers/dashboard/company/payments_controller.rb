class Dashboard::Company::PaymentsController < Dashboard::Company::BaseController
  def capture
    @order = @company.orders.find_by_number(params[:orders_received_id])
    @payment = @order.payments.find(params[:id])
    unless @order.paid?
      if @order.manual_payment?
        @payment.complete! unless @payment.state == 'completed'
      else
        near_me_payments = @order.near_me_payments.create!(
          subtotal_amount: @order.total_amount_without_fee,
          service_fee_amount_guest: @order.service_fee_amount_guest,
          service_fee_amount_host: @order.service_fee_amount_host
        )

        if near_me_payments.paid?
          @payment.complete! unless @payment.state == 'completed'
        else
          flash[:error] = t('flash_messages.payments.capture_failed')
          @payment.failure! unless @payment.failed?
          @order.create_pending_payment!
        end
      end
    else
      flash[:error] = t('flash_messages.payments.paid')
    end

    redirect_to dashboard_company_orders_received_path(@order)
  end
end
