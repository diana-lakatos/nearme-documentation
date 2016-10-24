class AddMinimumServiceFeeListerToTransactableTypeActionTypes < ActiveRecord::Migration
  def change
    add_column :transactable_type_action_types, :minimum_lister_service_fee_cents, :integer, default: 0
    add_column :line_items, :minimum_lister_service_fee_cents, :integer, default: 0
  end
end
