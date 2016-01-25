class InstanceAdmin::Manage::InstanceProfileTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def redirect_path
    instance_admin_manage_instance_profile_type_custom_validators_path(@validatable)
  end

  def find_validatable
    @validatable = InstanceProfileType.find(params[:instance_profile_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end

  def available_attributes
    @attributes = [
        :first_name, :middle_name, :last_name, :name, :phone, :mobile_number, :country_name, :current_location,
        :company_name, :avatar
    ]
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_manage_instance_profile_types_path, :title => t('instance_admin.manage.instance_profile_types.instance_profile_types') },
      {title: @validatable.try(:name)},
      { :url => instance_admin_manage_instance_profile_type_custom_validators_path, :title => t('instance_admin.manage.service_types.custom_validators') }
    )
  end
end
