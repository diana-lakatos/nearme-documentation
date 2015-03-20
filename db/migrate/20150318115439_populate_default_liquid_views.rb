class PopulateDefaultLiquidViews < ActiveRecord::Migration
  def up
    Instance.where(user_based_marketplace_views: true).each do |i|
      puts "#{i.name} is user based marketplace, populating default liquid views:"
      iv = InstanceView.where(instance_id: i.id, transactable_type_id: nil, path: 'locations/location_description', locale: 'en', partial: true, view_type: 'view', format: 'html', handler: 'liquid').first_or_initialize do |iv|
        iv.body = <<-BODY
<h2>{{ location.administrator.name }}</h2>
<p>{{ location.administrator.biography | filter_text | custom_sanitize }}</p>
        BODY
      end
      if iv.new_record?
        iv.save!
        puts "Created locations/location_description"
      end
      iv = InstanceView.where(instance_id: i.id, transactable_type_id: nil, path: 'locations/listings/listing_description', locale: 'en', partial: true, view_type: 'view', format: 'html', handler: 'liquid').first_or_initialize do |iv|
        iv.body = <<-BODY
<h2>{{ listing.administrator.name }}</h2>
<p>{{ listing.administrator.biography | filter_text | custom_sanitize }}</p>
        BODY
      end
      if iv.new_record?
        iv.save!
        puts "Created locations/listings/listing_description"
      end
    end
  end

  def down
  end
end

