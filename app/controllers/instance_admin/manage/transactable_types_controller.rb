class InstanceAdmin::Manage::TransactableTypesController < InstanceAdmin::Manage::BaseController

  def index
    @transactable_types = TransactableType.all
  end

end

