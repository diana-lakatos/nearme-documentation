class AddStartAndEndMinutesToReservationPeriods < ActiveRecord::Migration
  def change
    add_column :reservation_periods, :start_minute, :integer
    add_column :reservation_periods, :end_minute, :integer
  end
end
