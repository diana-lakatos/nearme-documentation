class InstanceAdmin::BuySell::ProductTypes::CustomAttributesController < InstanceAdmin::CustomAttributesController

  protected

  def resource_class
    Spree::ProductType
  end

  def permitting_controller_class
    @controller_scope ||= 'buy_sell'
    'buysell'
  end
end
