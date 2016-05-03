class InstanceAdmin::Manage::Instances::FormComponentsController < InstanceAdmin::FormComponentsController

  before_filter :form_type
  prepend_before_filter :find_form_componentable

  def find_form_componentable
    @form_componentable = PlatformContext.current.instance
  end

  def form_type
    @form_type = FormComponent::LOCATION_ATTRIBUTES
  end

  private

  def resource_class
    Instance
  end

end
