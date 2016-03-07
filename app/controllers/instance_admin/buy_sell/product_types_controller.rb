class InstanceAdmin::BuySell::ProductTypesController < InstanceAdmin::Manage::TransactableTypesController

  private

  def resource_class
    Spree::ProductType
  end

  def controller_scope
    @controller_scope ||= :buy_sell
  end

end

