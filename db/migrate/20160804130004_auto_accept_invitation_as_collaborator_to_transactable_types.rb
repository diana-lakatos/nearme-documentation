class AutoAcceptInvitationAsCollaboratorToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :auto_accept_invitation_as_collaborator, :boolean, default: false
  end
end
