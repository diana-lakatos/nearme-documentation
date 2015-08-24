class AddRentalShippingTypeToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :rental_shipping_type, :string, default: 'no_rental'
  end
end
