class AddRentalShippingToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :rental_shipping, :boolean, default: false
  end
end
