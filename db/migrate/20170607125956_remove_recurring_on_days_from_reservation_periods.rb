# frozen_string_literal: true
class RemoveRecurringOnDaysFromReservationPeriods < ActiveRecord::Migration
  def change
    remove_column :reservation_periods, :recurring_on_days, :integer, array: true
    add_index :reservation_periods, [:recurring_frequency, :recurring_frequency_unit], name: 'reservation_periods_frequency_index'
  end
end
