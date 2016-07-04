class InstanceAdmin::Manage::TransactableTypes::FormComponentsController < InstanceAdmin::FormComponentsController

  private

  def resource_class
    TransactableType
  end

end
