class InstanceAdmin::Manage::TransactableTypes::CategoriesController < InstanceAdmin::CategoriesController

  private

  def find_categorable
    @categorable = TransactableType.find(params[:transactable_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end
end
