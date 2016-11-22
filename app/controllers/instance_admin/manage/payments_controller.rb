# frozen_string_literal: true
class InstanceAdmin::Manage::PaymentsController < InstanceAdmin::Manage::BaseController
  skip_before_action :check_if_locked
  before_action :find_payment, except: :index

  def index
    params[:mode] ||= PlatformContext.current.instance.test_mode? ? PaymentGateway::TEST_MODE : PaymentGateway::LIVE_MODE

    @payment_gateways = PaymentGateway.all.sort_by(&:name)
    payments_scope = Payment.order('created_at DESC')
    payments_scope = payments_scope.where(state: params[:state]) if params[:state].present?
    payments_scope = payments_scope.where(payment_gateway_id: params[:payment_gateway_id]) if params[:payment_gateway_id].present?
    payments_scope = payments_scope.where(payment_gateway_mode: params[:mode])
    payments_scope = payments_scope.where(payer_id: params[:payer_id]) if params[:payer_id]
    payments_scope = case params[:transferred]
                     when 'awaiting', nil
                       payments_scope.needs_payment_transfer
                     when 'transferred'
                       payments_scope.transferred
                     when 'excluded'
                       payments_scope.where(exclude_from_payout: true)
                     else
                       payments_scope
    end if params[:payer_id].blank?

    @payments = PaymentDecorator.decorate_collection(payments_scope.paginate(per_page: 20, page: params[:page]))
  end

  def update
    flash[:notice] = if @payment.update_attributes(payment_params)
                       'Payment updated'
                     else
                       'Payment can not be updated'
                     end

    redirect_to instance_admin_manage_payment_path(@payment)
  end

  def reload
    PaymentReloaderService.new(@payment).process!
    redirect_to instance_admin_manage_payment_path(@payment)
  end

  private

  def find_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(secured_params.admin_paymnet)
  end
end
