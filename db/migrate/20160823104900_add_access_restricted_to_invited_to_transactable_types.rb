class AddAccessRestrictedToInvitedToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :access_restricted_to_invited, :boolean
  end
end
