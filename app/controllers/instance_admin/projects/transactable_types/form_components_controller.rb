class InstanceAdmin::Projects::TransactableTypes::FormComponentsController < InstanceAdmin::FormComponentsController
  before_filter :form_type, only: [:index]

  def create_as_copy
    project_type_id = params[:copy_template][:form_componentable_id]
    form_type = params[:copy_template][:form_type]
    TransactableType.find(project_type_id).form_components.where(form_type: form_type).each do |form_component|
      @form_componentable.form_components << form_component.dup
    end

    redirect_to redirect_path
  end

  private

  def resource_class
    TransactableType
  end

  def form_type
    @form_type = FormComponent::TRANSACTABLE_ATTRIBUTES
  end

  def find_form_componentable
    @form_componentable = TransactableType.find(params[:transactable_type_id])
  end

  def redirect_path
    instance_admin_projects_project_type_form_components_path(@form_componentable)
  end

  def permitting_controller_class
    @controller_scope ||= 'projects'
  end
end
