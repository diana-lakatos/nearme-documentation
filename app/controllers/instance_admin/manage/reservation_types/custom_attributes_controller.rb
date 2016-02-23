class InstanceAdmin::Manage::ReservationTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController

  protected

  def resource_class
    ReservationType
  end

end
