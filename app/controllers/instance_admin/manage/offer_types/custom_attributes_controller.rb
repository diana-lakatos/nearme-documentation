class InstanceAdmin::Manage::OfferTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController

  protected

  def resource_class
    OfferType
  end

end
