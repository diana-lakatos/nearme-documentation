# frozen_string_literal: true
class InstanceAdmin::Manage::UserProfilesController < InstanceAdmin::Manage::BaseController
  def change_approval_status
    resource
      .assign_attributes(approved: params[:enabled], enabled: params[:enabled])

    resource.save(validate: false)

    if resource.enabled
      WorkflowStepJob.perform(WorkflowStep::UserWorkflow::ProfileApproved, resource.user_id, as: current_user)
    end

    redirect_to request.referer.presence || instance_admin_manage_users_path
  end
end
