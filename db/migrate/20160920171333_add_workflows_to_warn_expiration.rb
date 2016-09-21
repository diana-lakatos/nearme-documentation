class AddWorkflowsToWarnExpiration < ActiveRecord::Migration
  def self.up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::ReservationCreator.new.warn_guest_of_reservation_expiration!
    end
  end
end
