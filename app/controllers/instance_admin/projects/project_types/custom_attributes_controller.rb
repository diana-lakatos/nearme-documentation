class InstanceAdmin::Projects::ProjectTypes::CustomAttributesController < InstanceAdmin::CustomAttributesController

  protected

  def redirection_path
    instance_admin_projects_project_type_custom_attributes_path(@target)
  end

  def find_target
    @target = ProjectType.find(params[:project_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'projects'
  end

  def resource_class
    ProjectType
  end
end
