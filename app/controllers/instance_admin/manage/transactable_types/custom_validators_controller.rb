class InstanceAdmin::Manage::TransactableTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController
  protected

  def resource_class
    TransactableType
  end

  def available_attributes
    @attributes = Transactable.column_names.map { |column| [column.humanize, column] }
  end
end
