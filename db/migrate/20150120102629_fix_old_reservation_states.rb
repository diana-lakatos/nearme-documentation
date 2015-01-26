class FixOldReservationStates < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE reservations
      SET
        state = 'cancelled_by_guest'
      WHERE state = 'cancelled'
    SQL
  end

  def down
  end
end
