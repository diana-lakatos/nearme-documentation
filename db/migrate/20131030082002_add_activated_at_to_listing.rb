class AddActivatedAtToListing < ActiveRecord::Migration

  class Listing < ActiveRecord::Base
  end

  def change
    add_column :listings, :activated_at, :datetime

    Listing.where(enabled: true).each do |listing|
      listing.activated_at = listing.created_at
      listing.save
    end
  end
end
