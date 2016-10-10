class TransactableDestroyerService
  def initialize(transactable, event_tracker, user)
    @transactable = transactable
    @event_tracker = event_tracker
    @user = user
  end

  def destroy
    @transactable.orders.reservations.each(&:perform_expiry!)
    @transactable.destroy
    @event_tracker.updated_profile_information(@user)
    @event_tracker.deleted_a_listing(@transactable)
  end
end
