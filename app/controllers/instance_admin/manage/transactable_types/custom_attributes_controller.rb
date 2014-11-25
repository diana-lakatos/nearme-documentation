class InstanceAdmin::Manage::TransactableTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController

  protected

  def redirection_path
    instance_admin_manage_transactable_type_custom_attributes_path(@target)
  end

  def find_target
    @target = TransactableType.find(params[:transactable_type_id])
  end
end
