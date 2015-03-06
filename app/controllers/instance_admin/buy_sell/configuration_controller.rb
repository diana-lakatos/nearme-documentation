class InstanceAdmin::BuySell::ConfigurationController < InstanceAdmin::BuySell::BaseController

  def update
    configuration_params.each do |name, value|
      next unless Spree::Config.has_preference? name
      Spree::Config[name] = value
    end
    flash[:success] = t('flash_messages.buy_sell.configuration_saved_successful')
    redirect_to instance_admin_buy_sell_configuration_path
  end

  private

  def configuration_params
    params.permit(secured_params.instance_admin_buy_sell_configuration)
  end

end

