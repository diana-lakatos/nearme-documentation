class AddPricingMaxMixValidationFieldsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :min_hourly_price_cents, :integer
    add_column :instances, :max_hourly_price_cents, :integer
    add_column :instances, :min_daily_price_cents, :integer
    add_column :instances, :max_daily_price_cents, :integer
    add_column :instances, :min_weekly_price_cents, :integer
    add_column :instances, :max_weekly_price_cents, :integer
    add_column :instances, :min_monthly_price_cents, :integer
    add_column :instances, :max_monthly_price_cents, :integer
  end
end
