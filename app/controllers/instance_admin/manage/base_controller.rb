class InstanceAdmin::Manage::BaseController < InstanceAdmin::ResourceController
  def index
    redirect_to instance_admin_manage_users_path
  end
end
