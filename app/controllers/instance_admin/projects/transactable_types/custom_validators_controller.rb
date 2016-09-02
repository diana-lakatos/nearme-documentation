class InstanceAdmin::Projects::TransactableTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def resource_class
    TransactableType
  end

  def redirect_path
    instance_admin_projects_transactable_type_custom_validators_path
  end

  def find_validatable
    @validatable = TransactableType.find(params[:transactable_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'projects'
  end

  def available_attributes
    @attributes = Transactable.column_names.map{ |column| [column.humanize, column] }
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_projects_transactable_types_path, :title => 'Project Type' },
      { :title => @validatable.name.titleize },
      { :url => redirect_path, :title => t('instance_admin.manage.project_types.custom_validators') }
    )
  end
end
