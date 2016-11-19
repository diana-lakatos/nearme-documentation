# frozen_string_literal: true
class InstanceAdmin::Settings::BaseController < InstanceAdmin::BaseController
  before_action :find_instance
  before_action :find_instance_translations

  def index
    redirect_to instance_admin_settings_configuration_path
  end

  def show
    find_or_build_billing_gateway_for_usd
  end

  def update
    if params[:instance].present?
      if @instance.update_attributes(instance_params)
        flash.now[:success] = t('flash_messages.instance_admin.settings.settings_updated')
        find_or_build_billing_gateway_for_usd
        redirect_to action: default_action
      else
        flash.now[:error] = @instance.errors.full_messages.to_sentence
        find_or_build_billing_gateway_for_usd
        render default_action
      end
    else
      find_or_build_billing_gateway_for_usd
      render default_action
    end
  end

  private

  def default_action
    :show
  end

  def find_or_build_billing_gateway_for_usd
    InstanceBillingGateway.find { |bg| bg.currency == 'USD' } || @instance.instance_billing_gateways.build(currency: 'USD')
  end

  def find_instance
    @instance = platform_context.instance
  end

  def find_instance_translations
    @translations = @instance.translations
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end
end
