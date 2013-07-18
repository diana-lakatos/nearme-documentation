class AddCurrencyToReservationCharges < ActiveRecord::Migration
  def change
    add_column :reservation_charges, :currency, :string
  end
end
