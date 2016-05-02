class AddDisplayAdditionalChargesToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :display_additional_charges, :boolean, default: true
  end
end
