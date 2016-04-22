class InstanceAdmin::Manage::OfferTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def resource_class
    OfferType
  end

  def available_attributes
    @attributes = Transactable.column_names.map{ |column| [column.humanize, column] }
  end

end
