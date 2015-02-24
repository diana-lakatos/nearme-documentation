class InstanceAdmin::Manage::TransactableTypes::FormComponentsController < InstanceAdmin::FormComponentsController

  private

  def find_form_componentable
    @form_componentable = TransactableType.find(params[:transactable_type_id])
  end

  def redirect_path
    instance_admin_manage_transactable_type_form_components_path(@form_componentable)
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end
end
