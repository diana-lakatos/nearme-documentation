class AddWorkflowsToReservationShippingInfo < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::ReservationCreator.new.create_notify_host_of_shipping_details_email!
      Utils::DefaultAlertsCreator::ReservationCreator.new.create_notify_guest_of_shipping_details_email!
    end
  end
end
