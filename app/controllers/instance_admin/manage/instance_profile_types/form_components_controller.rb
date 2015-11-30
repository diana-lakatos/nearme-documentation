class InstanceAdmin::Manage::InstanceProfileTypes::FormComponentsController < InstanceAdmin::FormComponentsController
  before_filter :form_type, only: [:index]

  private

  def form_type
    @form_type = case find_form_componentable.profile_type
                 when InstanceProfileType::DEFAULT
                   FormComponent::INSTANCE_PROFILE_TYPES
                 when InstanceProfileType::SELLER
                   FormComponent::SELLER_PROFILE_TYPES
                 when InstanceProfileType::BUYER
                   FormComponent::BUYER_PROFILE_TYPES
                 else
                   raise NotImplementedError.new("Unknown profile_type: #{find_form_componentable.profile_type}")
                 end
  end

  def find_form_componentable
    @form_componentable = InstanceProfileType.find(params[:instance_profile_type_id])
  end

  def redirect_path
    instance_admin_manage_instance_profile_type_form_components_path(@form_componentable)
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end
end
