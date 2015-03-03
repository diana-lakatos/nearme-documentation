class InstanceAdmin::BuySell::ProductTypes::CustomAttributesController < InstanceAdmin::CustomAttributesController

  protected

  def redirection_path
    instance_admin_buy_sell_product_type_custom_attributes_path(@target)
  end

  def find_target
    @target = Spree::ProductType.find(params[:product_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'buy_sell'
    'buysell'
  end
end
