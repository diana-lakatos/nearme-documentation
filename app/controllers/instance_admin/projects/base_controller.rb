module InstanceAdmin::Projects
  class BaseController < InstanceAdmin::BaseController
    def index
      redirect_to instance_admin_projects_project_types_path
    end
  end
end
