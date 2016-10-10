class InstanceAdmin::Manage::TransactableTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController
  protected

  def resource_class
    TransactableType
  end
end
