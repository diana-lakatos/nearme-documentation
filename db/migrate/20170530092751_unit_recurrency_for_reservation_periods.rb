class UnitRecurrencyForReservationPeriods < ActiveRecord::Migration
  def change
    add_column :reservation_periods, :recurring_frequency, :integer
    add_column :reservation_periods, :recurring_frequency_unit, :string
    remove_column :reservation_periods, :recurring_frequency_days, :integer
    add_index :reservation_periods, [:recurring_frequency, :recurring_frequency_unit, :recurring_on_days], name: 'reservation_periods_frequency_index'
  end
end
