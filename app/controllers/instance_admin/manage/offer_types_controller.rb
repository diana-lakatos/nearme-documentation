class InstanceAdmin::Manage::OfferTypesController < InstanceAdmin::Manage::TransactableTypesController

  private

  def resource_class
    OfferType
  end

end

