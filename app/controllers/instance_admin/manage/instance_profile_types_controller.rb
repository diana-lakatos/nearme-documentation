class InstanceAdmin::Manage::InstanceProfileTypesController < InstanceAdmin::Manage::TransactableTypesController

  def index
    @instance_profile_types = InstanceProfileType.order(:name)
  end

  def enable
    if (@instance_profile_type = InstanceProfileType.default.first).nil?
       @instance_profile_type = InstanceProfileType.create(name: "User Instance Profile")
      flash[:notice] = 'Custom attributes for user have been enabled'
    else
      flash[:error] = 'Custom attributes for user already enabled'
    end
    redirect_to instance_admin_manage_instance_profile_type_custom_attributes_path(@instance_profile_type)
  end

  private

  def resource_class
    InstanceProfileType
  end

  def transactable_type_params
    params.require(:instance_profile_type).permit(secured_params.instance_profile_type)
  end

end
