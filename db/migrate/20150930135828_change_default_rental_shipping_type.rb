class ChangeDefaultRentalShippingType < ActiveRecord::Migration
  def up
    change_column :transactables, :rental_shipping_type, :string, default: nil
  end

  def down
    change_column :transactables, :rental_shipping_type, :string, default: 'no_rental'
  end
end
