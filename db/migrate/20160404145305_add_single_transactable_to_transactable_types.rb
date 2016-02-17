class AddSingleTransactableToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :single_transactable, :boolean, default: false
  end
end
