class AddFixedPriceCentsToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :fixed_price_cents, :integer
    add_column :transactables, :min_fixed_price_cents, :integer
    add_column :transactables, :max_fixed_price_cents, :integer
  end
end
