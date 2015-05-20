class InstanceAdmin::BuySell::ProductTypes::CategoriesController < InstanceAdmin::CategoriesController

  private

  def find_categorizable
    @categorizable = Spree::ProductType.find(params[:product_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'buy_sell'
    'buysell'
  end
end
