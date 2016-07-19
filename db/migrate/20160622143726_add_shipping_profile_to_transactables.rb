class AddShippingProfileToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :shipping_profile_id, :integer, index: true
  end
end
