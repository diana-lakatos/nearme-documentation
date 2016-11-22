# frozen_string_literal: true
class InstanceAdmin::Manage::WebhooksController < InstanceAdmin::Manage::BaseController
  before_action :find_webhook, except: :index

  def index
    params[:mode] ||= PlatformContext.current.instance.test_mode? ? PaymentGateway::TEST_MODE : PaymentGateway::LIVE_MODE

    @payment_gateways = PaymentGateway.all.sort_by(&:name)
    webhook_scope = Webhook.order('created_at DESC')
    webhook_scope = webhook_scope.where('external_id like ?', "%#{params[:query]}%") if params[:query].present?
    webhook_scope = webhook_scope.where(state: params[:state]) if params[:state].present?
    webhook_scope = webhook_scope.where(payment_gateway_id: params[:payment_gateway_id]) if params[:payment_gateway_id].present?
    webhook_scope = webhook_scope.where(payment_gateway_mode: params[:mode])
    webhook_scope = webhook_scope.where(merchant_account_id: params[:merchant_account_id]) if params[:merchant_account_id]

    @webhooks = webhook_scope.paginate(per_page: 20, page: params[:page])
  end

  def retry
    @webhook.process! unless @webhook.archived?
    redirect_to instance_admin_manage_webhooks_path
  end

  def show
    render :show, layout: !request.xhr?
  end

  def destroy
    @webhook.destroy!
    flash[:notice] = t('flash_messages.instance_admin.manage.webhooks.deleted')
    redirect_to instance_admin_manage_webhooks_path
  end

  private

  def find_webhook
    @webhook = Webhook.find(params[:id])
  end
end
