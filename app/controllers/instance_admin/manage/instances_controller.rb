class InstanceAdmin::Manage::InstancesController < InstanceAdmin::Manage::BaseController
  # We created FormComponentsController under InstancesController otherwise it does not play along well with
  # the generic structure we have for adding form components to any entity
  def index
  end

  private
end
