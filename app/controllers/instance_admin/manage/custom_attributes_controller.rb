class InstanceAdmin::Manage::CustomAttributesController < InstanceAdmin::CustomAttributesController
  def permitting_controller_class
    @controller_scope ||= 'manage'
  end
end
