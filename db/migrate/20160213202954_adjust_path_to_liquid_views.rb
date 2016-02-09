class AdjustPathToLiquidViews < ActiveRecord::Migration
  def up
    puts "Updating InstanceViews - locations/ was removed, path will be changed to listings/"
    InstanceView.where('path LIKE ?', 'locations/listings/listing_description').update_all(path: 'listings/listing_description')
    InstanceView.where('path LIKE ?', 'locations/location_description').update_all(path: 'listings/location_description')
    InstanceView.where('path LIKE ?', 'locations/administrator').update_all(path: 'listings/administrator')
    InstanceView.where('path LIKE ?', 'locations/booking_module_call_to_actions').update_all(path: 'listings/booking_module_call_to_actions')
    InstanceView.where('path LIKE ?', 'locations/booking_module_listing_description').update_all(path: 'listings/booking_module_listing_description')
    InstanceView.where('path LIKE ?', 'locations/booking_module_listing_description_above_call_to_action').update_all(path: 'listings/booking_module_listing_description_above_call_to_action')
    InstanceView.where('path LIKE ?', 'locations/booking_module_listing_description_below_call_to_action').update_all(path: 'listings/booking_module_listing_description_below_call_to_action')
    InstanceView.where('path LIKE ?', 'locations/google_map').update_all(path: 'listings/google_map')
  end

  def down
  end
end
