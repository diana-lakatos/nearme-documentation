# frozen_string_literal: true
class PaymentSubscriptionDrop < BaseDrop
  # @return [PaymentSubscriptionDrop]
  attr_reader :payment_subscription

  # @!method id
  #   @return [Integer] numeric identifier for the payment subscription
  # @!method expired?
  #   @return (see PaymentSubscription#expired?)
  delegate :id, :expired?, to: :payment_subscription

  def initialize(payment_subscription)
    @payment_subscription = payment_subscription
  end
end
