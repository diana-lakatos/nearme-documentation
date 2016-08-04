class TransactableCollaboratorDrop < BaseDrop

  delegate :id, :user, :transactable, :approved_by_owner?, :approved_by_user?,
    :approved_by_user_at, :approved_by_owner_at, :transactable_id, :user_id,
    to: :source

end

