class InstanceAdmin::Manage::WorkflowsController < InstanceAdmin::Manage::BaseController
  before_action :find_workflow, only: [:show, :update]
  before_action :set_breadcrumbs_title

  def index
    @workflows = Workflow.all
  end

  def update
    if @workflow.update_attributes(workflow_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.workflows.updated'
      redirect_to instance_admin_manage_workflows_path
    else
      flash[:error] = @workflow.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private

  def find_workflow
    @workflow = Workflow.find(params[:id])
  end

  def set_breadcrumbs_title
    if action_name == 'show'
      @breadcrumbs_title = BreadcrumbsList.new(
        { title: t('instance_admin.workflows.manage_workflows'), url: instance_admin_manage_workflows_path },
        { title: @workflow.name }
      )
    else
      @breadcrumbs_title = t('instance_admin.workflows.manage_workflows')
    end
  end

  def workflow_params
    params.require(:workflow).permit(secured_params.workflow)
  end
end
