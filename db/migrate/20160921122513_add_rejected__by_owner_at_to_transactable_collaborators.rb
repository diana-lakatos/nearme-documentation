class AddRejectedByOwnerAtToTransactableCollaborators < ActiveRecord::Migration
  def change
    add_column :transactable_collaborators, :rejected_by_owner_at, :datetime
  end
end
