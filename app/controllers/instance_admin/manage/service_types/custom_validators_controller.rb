class InstanceAdmin::Manage::ServiceTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def redirect_path
    instance_admin_manage_service_type_custom_validators_path(@validatable)
  end

  def find_validatable
    @validatable = ServiceType.find(params[:service_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end

  def available_attributes
    @attributes = Transactable.column_names.map{ |column| [column.humanize, column] }
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_manage_service_types_path, :title => t('instance_admin.manage.service_types.service_types') },
      { :url => instance_admin_manage_service_type_custom_validators_path, :title => t('instance_admin.manage.service_types.custom_validators') }
    )
  end
end
