class TransactableCollaboratorDrop < BaseDrop

  delegate :id, :user, :transactable, :approved_by_owner?, :approved_by_user?, to: :source

end

