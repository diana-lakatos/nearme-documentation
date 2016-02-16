class DoNotManuallyAppendHostToListingUrl < ActiveRecord::Migration
  def up
    InstanceView.find_each do |iv|
      iv.update_attribute(:body, iv.body.gsub("platform_context.host | append:listing.listing_url", "listing.listing_url"))
      iv.update_attribute(:body, iv.body.gsub("platform_context.host | append:listing_in_near.listing_url", "listing_in_near.listing_url"))
      iv.update_attribute(:body, iv.body.gsub("platform_context.host | append:listing.url", "listing.listing_url"))



    end
  end

  def down
  end
end
