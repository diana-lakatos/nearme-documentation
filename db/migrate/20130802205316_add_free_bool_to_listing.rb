class AddFreeBoolToListing < ActiveRecord::Migration
  def up
    add_column :listings, :free, :boolean, :default => false

    # Any listing with all prices set to nil AFTER the 'free' checkbox
    # was introduced should have its free bool set to true
    connection.execute <<-SQL
      UPDATE listings
      SET free = TRUE
      WHERE created_at > '2012-11-06'
      AND hourly_price_cents is null
      AND daily_price_cents is null
      AND weekly_price_cents is null
      AND monthly_price_cents is null
    SQL

    connection.execute <<-SQL
      UPDATE listings
      SET deleted_at = CURRENT_TIMESTAMP
      WHERE created_at <= '2012-11-06'
      AND hourly_price_cents is null
      AND daily_price_cents is null
      AND weekly_price_cents is null
      AND monthly_price_cents is null
    SQL

  end

  def down
    remove_column :listings, :free
  end
end
