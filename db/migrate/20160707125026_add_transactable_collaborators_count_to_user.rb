class AddTransactableCollaboratorsCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :transactable_collaborators_count, :integer, null: false, default: 0
  end
end
