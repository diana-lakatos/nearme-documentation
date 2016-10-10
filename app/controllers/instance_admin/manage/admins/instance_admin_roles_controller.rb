class InstanceAdmin::Manage::Admins::InstanceAdminRolesController < InstanceAdmin::Manage::BaseController
  skip_before_filter :check_if_locked

  def index
    redirect_to instance_admin_manage_admins_path
  end

  def create
    @instance_admin_role = InstanceAdminRole.new(role_params)
    @instance_admin_role.instance_id = PlatformContext.current.instance.id
    if @instance_admin_role.save

      flash[:success] = t('flash_messages.instance_admin.admins.instance_admin_roles.role_added')
      redirect_to instance_admin_manage_admins_path
    else
      render 'instance_admin/manage/admins/index'
    end
  end

  def update
    @instance_admin_role = InstanceAdminRole.find(params[:id])
    if @instance_admin_role.instance_id.present?
      @instance_admin_role.update_attributes(role_params) if only_updates_permission?
    end
    render nothing: true
  end

  def destroy
    @instance_admin_role = InstanceAdminRole.find(params[:id])
    @instance_admin_role.destroy if @instance_admin_role.instance_id.present?
    flash[:deleted] = t('flash_messages.instance_admin.admins.instance_admin_roles.role_deleted')
    redirect_to instance_admin_manage_admins_path
  end

  private

  def only_updates_permission?
    params[:instance_admin_role].keys.all? { |iar| iar.include?('permission_') }
  end

  def permitting_controller_class
    'manage'
  end

  def role_params
    params.require(:instance_admin_role).permit(secured_params.instance_admin_role)
  end
end
