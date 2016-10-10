class InstanceAdmin::Manage::ProjectsController < InstanceAdmin::Manage::BaseController
  def edit
    @project = Project.find(params[:id])
    render layout: false
  end

  def update
    @project = Project.find(params[:id])
    @project.update_columns(params[:project])
    render layout: false
  end
end
