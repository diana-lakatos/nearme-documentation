class InstanceAdmin::Manage::OfferTypes::FormComponentsController < InstanceAdmin::FormComponentsController
  before_filter :form_type, only: [:index]

  private

  def resource_class
    OfferType
  end

  def form_type
    @form_type ||= FormComponent::OFFER_ATTRIBUTES
  end

end
