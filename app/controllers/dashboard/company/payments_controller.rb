class Dashboard::Company::PaymentsController < Dashboard::Company::BaseController
  before_filter :find_order
  before_filter :find_payment, only: [:show, :refund]

  def capture
    unless @order.paid?
      payment = @order.payment
      if payment.manual_payment?
        @order.payment_state = 'paid'
        @order.save!
      else
        payment.capture!
        @order.update_order
        flash[payment.paid? ? :notice : :error] = t("flash_messages.payments.capture_#{payment.paid? ? 'success' : 'failed'}")
      end
    else
      flash[:error] = t('flash_messages.payments.paid')
    end
    redirect_to :back
  end

  def show
  end

  def refund
    @payment.refund!
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
    @payment = @order.payment.decorate
  end
end
