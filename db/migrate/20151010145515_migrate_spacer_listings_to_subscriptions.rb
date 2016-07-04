class MigrateSpacerListingsToSubscriptions < ActiveRecord::Migration
  def up
    instance = Instance.find_by(name: 'Spacer')
    instance.try(:set_context!)
    instance.try(:transactable_type).try(:each) do |service_type|
      service_type.action_subscription_booking = true
      service_type.action_regular_booking = false
      service_type.action_weekly_booking = false
      service_type.action_monthly_booking = false
      service_type.action_daily_booking = false
      service_type.save!
      service_type.transactables.find_each do |listing|
        next if listing.action_subscription_booking
        listing.update_columns({
          action_subscription_booking: true,
          action_daily_booking: false,
          weekly_subscription_price_cents: listing.weekly_price_cents,
          monthly_subscription_price_cents: listing.monthly_price_cents,
          booking_type: 'subscription'
        })
        listing.touch
      end
    end
  end
end
