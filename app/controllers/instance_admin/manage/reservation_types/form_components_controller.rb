class InstanceAdmin::Manage::ReservationTypes::FormComponentsController < InstanceAdmin::FormComponentsController
  before_filter :form_type, only: [:index]

  private

  def resource_class
    ReservationType
  end

  def form_type
    @form_type ||= FormComponent::RESERVATION_ATTRIBUTES
  end
end
