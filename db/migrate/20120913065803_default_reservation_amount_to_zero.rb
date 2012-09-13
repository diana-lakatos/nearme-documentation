class DefaultReservationAmountToZero < ActiveRecord::Migration
  def up
    change_column :reservations, :total_amount_cents, :integer, default: 0
  end

  def down
    change_column :reservations, :total_amount_cents, :integer
  end
end
