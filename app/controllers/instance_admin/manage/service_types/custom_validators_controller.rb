class InstanceAdmin::Manage::ServiceTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def resource_class
    ServiceType
  end

  def available_attributes
    @attributes = Transactable.column_names.map{ |column| [column.humanize, column] }
  end

end
