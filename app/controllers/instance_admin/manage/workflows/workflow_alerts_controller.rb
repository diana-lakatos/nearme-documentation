class InstanceAdmin::Manage::Workflows::WorkflowAlertsController < InstanceAdmin::Manage::BaseController

  before_action :find_workflow_step
  before_action :find_custom_emails
  before_action :find_custom_email_layouts
  before_action :find_custom_smses

  def index
    @workflow_alerts = @workflow_step.workflow_alerts
  end

  def create
    @workflow_alert = @workflow_step.workflow_alerts.build(workflow_alert_params)
    if @workflow_alert.save
      flash[:success] = t 'flash_messages.instance_admin.manage.workflow_alerts.created'
      redirect_to instance_admin_manage_workflow_workflow_step_path(@workflow_step.workflow, @workflow_step)
    else
      flash.now[:error] = @workflow_alert.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @workflow_alert = @workflow_step.workflow_alerts.find(params[:id])
    if @workflow_alert.update_attributes(workflow_alert_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.workflow_alerts.updated'
      redirect_to instance_admin_manage_workflow_workflow_step_path(@workflow_step.workflow, @workflow_step)
    else
      flash.now[:error] = @workflow_alert.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @workflow_alert = @workflow_step.workflow_alerts.find(params[:id])
    @workflow_alert.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.workflow_alerts.updated'
    redirect_to instance_admin_manage_workflow_workflow_step_path(@workflow_step.workflow, @workflow_step)
  end

  private

  def find_workflow_step
    @workflow_step = WorkflowStep.find(params[:workflow_step_id])
  end

  def workflow_alert_params
    params.require(:workflow_alert).permit(secured_params.workflow_alert(@workflow_step.associated_class))
  end

  def find_custom_smses
    @custom_smses =  InstanceView.all_sms_template_layouts_paths
  end

  def find_custom_emails
    @custom_emails =  if @workflow_step.associated_class.constantize.belongs_to_transactable_type?
      InstanceView.all_email_templates_paths
    else
      InstanceView.email_templates_paths_wo_transactable_type
    end
  end

  def find_custom_email_layouts
    @custom_email_layouts = InstanceView.all_email_template_layouts_paths
  end

  def permitting_controller_class
    'manage'
  end
end

