class TransactableCollaboratorDrop < BaseDrop
  delegate :id, :user, :transactable, :approved_by_owner?, :approved_by_user?,
           :approved_by_user_at, :approved_by_owner_at, :transactable_id, :user_id, :created_at,
           :rejected_by_owner_at, :rejected_by_owner?, to: :source

  def enquirerer_destroy_path
    routes.listing_transactable_collaborator_path(transactable, @source)
  end

  def destroy_path
    routes.dashboard_company_transactable_type_transactable_transactable_collaborator_path(transactable.transactable_type, transactable, @source)
  end

  def update_path
    routes.dashboard_company_transactable_type_transactable_transactable_collaborator_path(transactable.transactable_type, transactable, @source)
  end

  def transactable_user_messages
    @source.transactable.user_messages.where('author_id = :user_id OR thread_recipient_id = :user_id', user_id: @source.user_id)
  end

  def status
    return 'Pending' if approved_by_owner_at.nil? && rejected_by_owner_at.nil?

    return 'Rejected' if rejected_by_owner_at.present?
    return 'Approved' if approved_by_owner_at.present?
  end
end
