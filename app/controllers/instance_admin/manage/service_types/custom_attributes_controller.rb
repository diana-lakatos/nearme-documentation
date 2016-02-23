class InstanceAdmin::Manage::ServiceTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController

  protected

  def resource_class
    ServiceType
  end

end
