class InstanceAdmin::Manage::TransactableTypes::FormComponentsController < InstanceAdmin::FormComponentsController

  before_filter :set_breadcrumbs_title

  def create_as_copy
    transactable_type_id = params[:copy_template][:form_componentable_id]
    form_type = params[:copy_template][:form_type]

    transactable_type = TransactableType.where(:instance_id => PlatformContext.current.instance, :id => transactable_type_id).first

    transactable_type.form_components.where(:form_type => form_type).each do |form_component|
      @form_componentable.form_components << form_component.dup
    end

    redirect_to redirect_path
  end

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

  def set_breadcrumbs_title
    @breadcrumbs_title = 'Service Types'
  end
end
