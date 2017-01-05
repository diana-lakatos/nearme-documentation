class AddFixedPriceToTransactableTypePricings < ActiveRecord::Migration
  def change
    add_column :transactable_type_pricings, :fixed_price_cents, :integer
  end
end
