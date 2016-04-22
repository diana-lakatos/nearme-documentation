class PopulateOverdueEmails < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      puts "Creating overdue emails for #{i.name}"
      i.set_context!
      creator = Utils::DefaultAlertsCreator::RecurringBookingCreator.new
      creator.notify_host_recurring_booking_payment_overdue_email!
      creator.notify_guest_recurring_booking_payment_overdue_email!
      creator.notify_host_recurring_booking_payment_information_updated_email!
    end
  end

  def down
  end
end
