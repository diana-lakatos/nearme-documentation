class InstanceAdmin::BuySell::ProductTypes::FormComponentsController < InstanceAdmin::FormComponentsController
  before_filter :form_type, only: [:index]

  private

  def resource_class
    Spree::ProductType
  end

  def form_type
    @form_type = 'product_attributes'
  end

  def permitting_controller_class
    @controller_scope ||= 'buy_sell'
    'buysell'
  end
end
