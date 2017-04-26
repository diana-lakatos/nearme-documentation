class InstanceAdmin::Manage::Workflows::WorkflowStepsController < InstanceAdmin::Manage::BaseController
  before_action :find_workflow
  before_action :find_workflow_step, only: [:show, :update]
  before_action :set_breadcrumbs_title

  def update
    if @workflow_step.update_attributes(workflow_step_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.workflow_steps.updated'
      redirect_to instance_admin_manage_workflow_path(@workflow)
    else
      flash[:error] = @workflow_step.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private

  def find_workflow
    @workflow = Workflow.find(params[:workflow_id])
  end

  def workflow_step_params
    params.require(:workflow_step).permit(secured_params.workflow_step)
  end

  def permitting_controller_class
    'manage'
  end

  def find_workflow_step
    @workflow_step = @workflow.workflow_steps.find(params[:id])
  end

  def set_breadcrumbs_title
    return if action_name != 'show'

    @breadcrumbs_title = BreadcrumbsList.new(
      { title: t('instance_admin.workflows.manage_workflows'), url: instance_admin_manage_workflows_path },
      { title: @workflow.name, url: instance_admin_manage_workflow_path(@workflow) },
      { title: @workflow_step.name }
    )
  end
end
