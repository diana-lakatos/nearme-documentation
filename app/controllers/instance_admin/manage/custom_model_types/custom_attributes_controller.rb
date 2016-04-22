class InstanceAdmin::Manage::CustomModelTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController

  protected

  def resource_class
    CustomModelType
  end

end
