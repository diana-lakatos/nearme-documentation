class InstanceAdmin::BuySell::ProductTypes::FormComponentsController < InstanceAdmin::FormComponentsController

  private

  def find_form_componentable
    @form_componentable = Spree::ProductType.find(params[:product_type_id])
  end

  def redirect_path
    instance_admin_buy_sell_product_type_form_components_path(@form_componentable)
  end

  def permitting_controller_class
    @controller_scope ||= 'buy_sell'
  end
end
