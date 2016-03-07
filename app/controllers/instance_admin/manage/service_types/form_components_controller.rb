class InstanceAdmin::Manage::ServiceTypes::FormComponentsController < InstanceAdmin::FormComponentsController

  private

  def resource_class
    ServiceType
  end

end
