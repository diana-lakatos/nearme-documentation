class InstanceAdmin::Manage::InstanceProfileTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController

  protected

  def redirection_path
    instance_admin_manage_instance_profile_type_custom_attributes_path(@target)
  end

  def find_target
    @target = InstanceProfileType.find(params[:instance_profile_type_id])
  end
end
