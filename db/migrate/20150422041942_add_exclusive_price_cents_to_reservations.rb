class AddExclusivePriceCentsToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :exclusive_price_cents, :integer
  end
end
