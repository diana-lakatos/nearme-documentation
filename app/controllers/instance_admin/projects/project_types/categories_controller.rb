class InstanceAdmin::Projects::ProjectTypes::CategoriesController < InstanceAdmin::CategoriesController

  private

  def find_categorizable
    @categorizable = ProjectType.find(params[:project_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'projects'
  end
end
