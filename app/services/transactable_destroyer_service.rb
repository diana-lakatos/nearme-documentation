class TransactableDestroyerService
  def initialize(transactable)
    @transactable = transactable
  end

  def destroy
    @transactable.orders.reservations.each(&:perform_expiry!)
    @transactable.destroy
  end
end
