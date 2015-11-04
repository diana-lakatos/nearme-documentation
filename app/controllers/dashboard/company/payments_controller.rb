class Dashboard::Company::PaymentsController < Dashboard::Company::BaseController
  before_filter :find_order
  before_filter :find_payment, only: [:show, :refund]

  def create
    unless @order.paid?
      if @order.manual_payment?
        @order.payment_status = 'paid'
      else
        payment = @order.near_me_payments.create!(
          subtotal_amount: @order.total_amount_without_fee,
          service_fee_amount_guest: @order.service_fee_amount_guest,
          service_fee_amount_host: @order.service_fee_amount_host
        )

        @order.update_order
        flash[payment.paid? ? :notice : :error] = t("flash_messages.payments.capture_#{payment.paid? ? 'success' : 'failed'}")
      end
    else
      flash[:error] = t('flash_messages.payments.paid')
    end

    redirect_to dashboard_company_orders_received_path(@order)
  end

  def show
  end

  def refund
    @payment.refund
    if @payment.refunded? && @order.update_order
      flash[:notice] = t('flash_messages.payments.refunded')
    else
      flash[:error] = t('flash_messages.payments.refund_failed')
    end
    redirect_to :back
  end

  private

  def find_order
    @order = @company.orders.find_by_number(params[:orders_received_id])
  end

  def find_payment
    @payment = @order.near_me_payments.find(params[:id])
  end
end
