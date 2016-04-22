class PopulateForcePenaltyChargeEmail < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.set_context!
      creator = Utils::DefaultAlertsCreator::ReservationCreator.new
      creator.notify_guest_of_penalty_charge_failed!
      creator.notify_guest_of_penalty_charge_succeeded!
    end
  end

  def down
  end
end
