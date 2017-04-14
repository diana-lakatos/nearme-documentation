# frozen_string_literal: true
class ShoppingCartDrop < BaseDrop
  # @!method id
  #   @return [Integer] the id of the shopping cart
  # @!method orders
  #   @return [Order] array of associated orders
  # @!method reservations
  #   @return [Reservation] array of associated orders of type Reservation
  delegate :id, :orders, :reservations, to: :source
end
