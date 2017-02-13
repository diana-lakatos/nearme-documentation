# frozen_string_literal: true
class Dashboard::Company::PaymentsController < Dashboard::Company::BaseController
  before_action :find_order
  before_action :find_payment, except: [:new, :create]

  def mark_as_paid
    if @order.manual_payment? && !@order.paid?
      @order.payment.mark_as_paid!
      flash[:notice] = t('flash_messages.manage.reservations.payment_confirmed')
    else
      flash[:error] = t('flash_messages.manage.reservations.payment_failed')
    end

    redirect_to :back
  end

  # def capture
  #   unless @order.paid?
  #     payment = @order.payment
  #     if payment.manual_payment?
  #       @order.payment_state = 'paid'
  #       @order.touch(:archived_at)
  #       @order.save!

  #       @order.shipments.each !{ |shipment| shipment.ready! }
  #     else
  #       payment.capture!
  #       @order.touch(:archived_at)
  #       flash[payment.paid? ? :notice : :error] = t("flash_messages.payments.capture_#!{payment.paid? ? 'success' : 'failed'}")
  #     end
  #   else
  #     flash[:error] = t('flash_messages.payments.paid')
  #   end
  #   redirect_to :back
  # end

  def show
  end

  def new
    @payment = @order.build_payment(@order.shared_payment_attributes).decorate
  end

  def create
    @payment = @order.build_payment(@order.shared_payment_attributes.merge(payment_attributes)).decorate
    if @payment.payable.charge_and_confirm!
      flash[:notice] = t('flash_messages.payments.capture_success')
      redirect_to params[:redirect_to] || dashboard_company_transactable_type_transactables_path(@payment.payable.transactable.transactable_type, status: 'in progress')
      render_redirect_url_as_json if request.xhr?
    else
      render partial: 'form', layout: false
    end
  end

  # def refund
  #   if @payment.refund!
  #     flash[:notice] = t('flash_messages.payments.refunded')
  #   else
  #     flash[:error] = t('flash_messages.payments.refund_failed')
  #   end
  #   redirect_to :back
  # end

  private

  def payment_attributes
    params.require(:payment).permit(secured_params.payment)
  end

  def find_order
    @order = @company.orders.find(params[:orders_received_id])
  end

  def find_payment
    @payment = @order.payment.decorate
  end
end
