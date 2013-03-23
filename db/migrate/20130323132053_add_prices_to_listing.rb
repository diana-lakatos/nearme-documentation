class AddPricesToListing < ActiveRecord::Migration
  def change
    add_column :listings, :daily_price_cents, :integer
    add_column :listings, :weekly_price_cents, :integer
    add_column :listings, :monthly_price_cents, :integer
  end
end
