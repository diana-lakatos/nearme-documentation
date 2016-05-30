class RemovePricingOptionsFromInstance < ActiveRecord::Migration
  def change
    remove_column :instances, :pricing_options
    remove_column :instances, :min_hourly_price_cents
    remove_column :instances, :max_hourly_price_cents
    remove_column :instances, :min_daily_price_cents
    remove_column :instances, :max_daily_price_cents
    remove_column :instances, :min_weekly_price_cents
    remove_column :instances, :max_weekly_price_cents
    remove_column :instances, :min_monthly_price_cents
    remove_column :instances, :max_monthly_price_cents
  end
end
