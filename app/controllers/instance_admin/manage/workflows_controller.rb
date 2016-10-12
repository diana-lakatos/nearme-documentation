class InstanceAdmin::Manage::WorkflowsController < InstanceAdmin::Manage::BaseController
  before_filter :set_breadcrumbs

  def index
    @workflows = Workflow.all
  end

  def update
    @workflow = Workflow.find(params[:id])
    if @workflow.update_attributes(workflow_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.workflows.updated'
      redirect_to instance_admin_manage_workflows_path
    else
      flash[:error] = @workflow.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private

  def set_breadcrumbs
    @breadcrumbs_title = 'Manage Workflows'
  end

  def workflow_params
    params.require(:workflow).permit(secured_params.workflow)
  end
end
