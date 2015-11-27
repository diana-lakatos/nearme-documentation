class InstanceAdmin::Manage::InstanceProfileTypesController < InstanceAdmin::Manage::BaseController

  before_filter :set_breadcrumbs

  def index
    @instance_profile_types = InstanceProfileType.all
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

  def destroy
    @instance_profile_type = InstanceProfileType.find(params[:id])
    @instance_profile_type.destroy
    flash[:notice] = 'Custom attributes for user have been disabled'
    redirect_to instance_admin_manage_instance_profile_types_path
  end


  private

  def set_breadcrumbs
    @breadcrumbs_title = 'Manage Attributes'
  end

end
