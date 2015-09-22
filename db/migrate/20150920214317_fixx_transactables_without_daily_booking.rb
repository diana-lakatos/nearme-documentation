class FixxTransactablesWithoutDailyBooking < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      instance.listings.where(action_daily_booking: false, booking_type: 'regular').
        where("
          COALESCE(daily_price_cents, 0) != 0 OR
          COALESCE(monthly_price_cents, 0) != 0 OR
          COALESCE(weekly_price_cents, 0) != 0 AND
          action_hourly_booking IS NOT TRUE AND
          action_free_booking IS NOT TRUE").update_all(action_daily_booking: true)
      end
  end
end
