class AddDraftTimestampToListing < ActiveRecord::Migration
  def change
    add_column :listings, :draft, :datetime
  end
end
