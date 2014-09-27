class InstanceAdmin::Manage::BaseController < InstanceAdmin::ResourceController
  def index
    redirect_to instance_admin_manage_inventories_path
  end
end
