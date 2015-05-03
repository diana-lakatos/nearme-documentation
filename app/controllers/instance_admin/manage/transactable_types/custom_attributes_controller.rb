class InstanceAdmin::Manage::TransactableTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController

  before_filter :set_breadcrumbs_title

  protected

  def redirection_path
    instance_admin_manage_transactable_type_custom_attributes_path(@target)
  end

  def find_target
    @target = TransactableType.find(params[:transactable_type_id])
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = 'Service Types'
  end
end
