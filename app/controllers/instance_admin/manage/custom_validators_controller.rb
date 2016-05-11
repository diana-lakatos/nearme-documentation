class InstanceAdmin::Manage::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def resource_class
    Instance
  end

  def collection
    @validators ||= @validatable.custom_validators.where(validatable_id: nil)
  end

  def redirect_path
    instance_admin_manage_custom_validators_path
  end

  def find_validatable
    @validatable ||= current_instance
  end

  def available_attributes
    @attributes ||= {
      'Location' => [:email, :description, :address, :info, :special_notes, :name, :location_type_id]
    }
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_manage_custom_validators_path, :title => t('instance_admin.manage.transactable_types.custom_validators') }
    )
  end
end
