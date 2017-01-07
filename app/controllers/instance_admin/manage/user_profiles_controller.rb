# frozen_string_literal: true
class InstanceAdmin::Manage::UserProfilesController < InstanceAdmin::Manage::BaseController
  def approve
    resource.approved = true
    resource.enabled = true
    resource.save(validate: false)
    redirect_to request.referer.presence || instance_admin_manage_users_path
  end
end
