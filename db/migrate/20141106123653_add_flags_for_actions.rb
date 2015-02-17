class AddFlagsForActions < ActiveRecord::Migration
  class TransactableType < ActiveRecord::Base
    serialize :pricing_options, Hash
  end

  def up
    add_column :transactable_types, :action_rfq, :boolean, default: false
    add_column :transactable_types, :action_hourly_booking, :boolean, default: false
    add_column :transactable_types, :action_free_booking, :boolean, default: false
    add_column :transactable_types, :action_daily_booking, :boolean, default: false
    add_column :transactable_types, :action_monthly_booking, :boolean, default: false
    add_column :transactable_types, :action_weekly_booking, :boolean, default: false

    rename_column :transactable_types, :recurring_booking, :action_recurring_booking

    add_column :transactables, :action_rfq, :boolean, default: false
    add_column :transactables, :action_hourly_booking, :boolean, default: false
    add_column :transactables, :action_free_booking, :boolean, default: false
    add_column :transactables, :action_recurring_booking, :boolean, default: false
    add_column :transactables, :action_daily_booking, :boolean, default: false

    connection.execute <<-SQL
      UPDATE transactables
      SET
        action_free_booking = COALESCE(properties->'free', 'f')::bool,
        action_hourly_booking = COALESCE(properties->'hourly_reservations', 'f')::bool
    SQL

    TransactableType.all.each do |tt|
      tt.action_daily_booking = tt.pricing_options['daily']
      tt.action_weekly_booking = tt.pricing_options['weekly']
      tt.action_monthly_booking = tt.pricing_options['monthly']
      tt.action_hourly_booking = tt.pricing_options['hourly']
      tt.action_free_booking = tt.pricing_options['free']
      tt.save(validate: false)
    end

  end

  def down
    remove_column :transactable_types, :action_rfq
    remove_column :transactable_types, :action_hourly_booking
    remove_column :transactable_types, :action_free_booking
    remove_column :transactable_types, :action_daily_booking
    remove_column :transactable_types, :action_monthly_booking
    remove_column :transactable_types, :action_weekly_booking

    rename_column :transactable_types, :action_recurring_booking, :recurring_booking

    remove_column :transactables, :action_rfq
    remove_column :transactables, :action_hourly_booking
    remove_column :transactables, :action_free_booking
    remove_column :transactables, :action_recurring_booking
    remove_column :transactables, :action_daily_booking



  end
end
