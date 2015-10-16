class InstanceAdmin::Projects::BaseController < InstanceAdmin::ResourceController
  def index
    redirect_to instance_admin_projects_project_types_path
  end
end
