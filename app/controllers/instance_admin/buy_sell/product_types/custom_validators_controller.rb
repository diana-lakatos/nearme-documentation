class InstanceAdmin::BuySell::ProductTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def resource_class
    Spree::ProductType
  end

  def permitting_controller_class
    @controller_scope ||= 'buy_sell'
    'buysell'
  end

  def available_attributes
    @attributes = Spree::Product.column_names.map{ |column| [column.humanize, column] }
  end

end
