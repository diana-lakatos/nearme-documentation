class InstanceAdmin::Manage::TransactableTypes::CategoriesController < InstanceAdmin::CategoriesController

  before_filter :set_breadcrumbs_title

  private

  def find_categorable
    @categorable = TransactableType.find(params[:transactable_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = 'Service Types'
  end
end
