class AddUnitPriceCentsToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :unit_price_cents, :integer
  end
end
