class TransactableCollaboratorDrop < BaseDrop

  delegate :id, :user, :transactable, :approved_by_owner?, :approved_by_user?,
    :approved_by_user_at, :approved_by_owner_at, :transactable_id, :user_id,
    to: :source

  def destroy_path
    routes.dashboard_company_transactable_type_transactable_transactable_collaborator_path(transactable.transactable_type, transactable, @source)
  end

  def transactable_user_messages
    @source.transactable.user_messages.where("author_id = :user_id OR thread_recipient_id = :user_id", user_id: @source.user_id)
  end

end

