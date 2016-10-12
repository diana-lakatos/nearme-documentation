class InstanceAdmin::Manage::InstanceProfileTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController
  protected

  def resource_class
    InstanceProfileType
  end
end
