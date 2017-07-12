class InstanceAdmin::Settings::Payments::WebhookConfigurationsController < InstanceAdmin::Settings::BaseController
  def index
    @payment_gateway = payment_gateway
    @webhook_configurations = @payment_gateway.webhook_configurations
  end

  def new
    webhook_configuration = payment_gateway.webhook_configurations.new
    webhook_configuration.save
    redirect_to edit_instance_admin_settings_payment_gateway_webhook_configuration_path(payment_gateway, webhook_configuration)
  end

  def edit
    @webhook_configuration = payment_gateway.webhook_configurations.find params[:id]
  end

  def update
    @webhook_configuration = payment_gateway.webhook_configurations.find params[:id]
    if @webhook_configuration.update_attributes(webhook_configuration_params)
      redirect_to redirect_url
    else
      render action: :edit
    end
  end

  def destroy
    @webhook_configuration = payment_gateway.webhook_configurations.find params[:id]
    @webhook_configuration.destroy
    redirect_to redirect_url
  end

  private

  def webhook_configuration_params
    params.require(:webhook_configuration).permit(secured_params.webhook_configuration)
  end

  def redirect_url
    instance_admin_settings_payment_gateway_webhook_configurations_path(payment_gateway)
  end

  def payment_gateway
    @payment_gateway = PaymentGateway.find(params[:payment_gateway_id])
  end

  def permitting_controller_class
    'Webhook Settings'
  end
end
