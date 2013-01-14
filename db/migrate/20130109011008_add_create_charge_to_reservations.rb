class AddCreateChargeToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :create_charge, :boolean
  end
end
