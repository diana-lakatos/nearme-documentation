class InstanceAdmin::BuySell::ConfigurationController < InstanceAdmin::BuySell::BaseController

  def update
    configuration_params.each do |name, value|
      next unless Spree::Config.has_preference? name
      Spree::Config[name] = value
    end
    platform_context.instance.update_attribute(:possible_manual_payment, params[:possible_manual_payment])

    update_relevant_translations
    flash[:success] = t('flash_messages.buy_sell.configuration_saved_successful')
    redirect_to instance_admin_buy_sell_configuration_path
  end

  private

  def configuration_params
    params.permit(secured_params.instance_admin_buy_sell_configuration)
  end

  def update_relevant_translations
    return unless params[:translations]
    %w(buy_sell_market.checkout.manual_payment buy_sell_market.checkout.manual_payment_description).each do |key|
      t = Translation.where(instance_id: PlatformContext.current.instance.id, key: key, locale: I18n.locale).first_or_initialize
      t.update_attribute(:value, params[:translations][key])
    end
  end
end
