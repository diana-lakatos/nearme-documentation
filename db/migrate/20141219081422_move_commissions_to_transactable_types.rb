class MoveCommissionsToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :service_fee_guest_percent, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :transactable_types, :service_fee_host_percent, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :transactable_types, :bookable_noun, :string
    add_column :transactable_types, :lessor, :string
    add_column :transactable_types, :lessee, :string
  end
end
