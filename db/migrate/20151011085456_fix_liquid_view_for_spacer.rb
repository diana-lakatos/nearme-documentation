class FixLiquidViewForSpacer < ActiveRecord::Migration
  def up
    instance = Instance.find_by(name: 'Spacer')
    instance.set_context!
    iv = instance.instance_views.find_by(path: 'locations/booking_module_listing_description_below_dates')
    iv.body = iv.body.gsub('reservation[guest_notes]', 'recurring_booking[guest_notes]')
    iv.save!
  end
end
