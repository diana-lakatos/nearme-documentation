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
end
