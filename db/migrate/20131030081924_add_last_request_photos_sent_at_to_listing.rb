class AddLastRequestPhotosSentAtToListing < ActiveRecord::Migration
  def change
    add_column :listings, :last_request_photos_sent_at, :datetime
  end
end
