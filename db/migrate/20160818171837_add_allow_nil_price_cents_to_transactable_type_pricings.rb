class AddAllowNilPriceCentsToTransactableTypePricings < ActiveRecord::Migration
  def change
    add_column :transactable_type_pricings, :allow_nil_price_cents, :boolean, default: false
  end
end
