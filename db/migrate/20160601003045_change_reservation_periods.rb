class ChangeReservationPeriods < ActiveRecord::Migration
  def change
    rename_column :reservation_periods, :reservation_id, :old_reservation_id
    add_column :reservation_periods, :reservation_id, :integer, index: true
  end
end
