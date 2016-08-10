class AddRequireTransactableToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :require_transactable_during_onboarding, :boolean, default: true
  end
end
