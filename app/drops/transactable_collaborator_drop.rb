# frozen_string_literal: true
class TransactableCollaboratorDrop < BaseDrop
  # @!method id
  #   @return [Integer] numeric identifier for this transactable collaborator
  # @!method user
  #   @return [User] User object representing the collaborating user
  # @!method transactable
  #   @return [TransactableDrop] Transactable being collaborated on
  # @!method approved_by_owner?
  #   @return [Boolean] whether the collaboration has been approved by the transactable creator
  # @!method approved_by_user?
  #   @return [Boolean] whether the colllaboration has been approved by the collaborating user
  # @!method approved_by_user_at
  #   Time when the collaborating user has approved the collaboration (if approved, otherwise nil)
  #   @return (see TransactableCollaborator#approved_by_user_at)
  # @!method approved_by_owner_at
  #   Time when the transactable creator has approved the collaboration (if approved, otherwise nil)
  #   @return (see TransactableCollaborator#approved_by_owner_at)
  # @!method transactable_id
  #   @return [Integer] Numeric identifier of the transactable being collaborated on
  # @!method user_id
  #   @return [Integer] Numeric identifier of the collaborating user
  delegate :id, :user, :transactable, :approved_by_owner?, :approved_by_user?,
           :approved_by_user_at, :approved_by_owner_at, :transactable_id, :user_id, :created_at,
           :rejected_by_owner_at, :rejected_by_owner?, to: :source


  # @return [String] url for the enquirer to cancel its collaboration request
  #   (must be used with the delete HTTP method)
  def enquirerer_destroy_path
    routes.listing_transactable_collaborator_path(transactable, @source)
  end

  # @return [String] path to the app location for removing the collaboration
  def destroy_path
    routes.dashboard_company_transactable_type_transactable_transactable_collaborator_path(transactable.transactable_type, transactable, @source)
  end

  # @return [String] url to update the transactable collaborator object e.g. for the owner to accept or to reject the collaboration
  #   ```
  #    {% form_for transactable_collaborator, url: @transactable_collaborator.update_path, method: 'put', remote: true %}
  #      <input type='hidden' name='transactable_collaborator[approved_by_owner_at]' value=''>
  #      <input type='hidden' name='transactable_collaborator[rejected_by_owner_at]' value='{{ "now" | parse_time }}'>
  #      <input type='submit' class="btn btn-danger" data-confirm="Are you sure?" value='Reject'>
  #    {% endform_for %}
  #
  #   ```
  def update_path
    routes.dashboard_company_transactable_type_transactable_transactable_collaborator_path(transactable.transactable_type, transactable, @source)
  end

  # @return [Array<UserMessageDrop>] array of user messages associated with the transactable collaborated on; used
  #   for discussion between clients and hosts
  def transactable_user_messages
    @source.transactable.user_messages.where('author_id = :user_id OR thread_recipient_id = :user_id', user_id: @source.user_id)
  end

  # @return [String] status of the transactable collaborator object i.e.
  #   * Pending if not approved nor rejected by owner
  #   * Rejected if rejected by owner
  #   * Approved if approved by owner
  def status
    return 'Pending' if approved_by_owner_at.nil? && rejected_by_owner_at.nil?

    return 'Rejected' if rejected_by_owner_at.present?
    return 'Approved' if approved_by_owner_at.present?
  end
end
