class InstanceAdmin::Projects::ProjectTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def redirect_path
    instance_admin_projects_project_type_custom_validators_path
  end

  def find_validatable
    @validatable = ProjectType.find(params[:project_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'projects'
  end

  def available_attributes
    @attributes = Project.column_names.map{ |column| [column.humanize, column] }
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_projects_project_types_path, :title => 'Project Type' },
      { :title => @validatable.name.titleize },
      { :url => redirect_path, :title => t('instance_admin.manage.service_types.custom_validators') }
    )
  end
end
