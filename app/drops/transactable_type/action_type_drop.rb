# frozen_string_literal: true
class TransactableType::ActionTypeDrop < BaseDrop
  # @return [TransactableType::ActionTypeDrop]

  # @!method id
  #   @return [Integer] numeric identifier for the transactable type action type
  # @!method pricings
  #   @return [Array<TransactableType::PricingDrop>] array of pricings
  delegate :id, :pricings, to: :source

end
