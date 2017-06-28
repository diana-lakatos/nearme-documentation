# frozen_string_literal: true
class AddReccurrencyToReservationPeriods < ActiveRecord::Migration
  def change
    add_column :reservation_periods, :recurring_frequency_days, :integer
    add_column :reservation_periods, :recurring_on_days, :integer, array: true
    add_index :reservation_periods, [:recurring_frequency_days, :recurring_on_days], name: 'reservation_periods_frequency_index'
  end
end
