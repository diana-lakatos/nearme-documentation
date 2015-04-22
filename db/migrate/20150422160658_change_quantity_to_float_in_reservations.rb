class ChangeQuantityToFloatInReservations < ActiveRecord::Migration
  def up
    change_column :reservations, :quantity, :float
  end

  def down
    change_column :reservations, :quantity, :integer
  end
end
