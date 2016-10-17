class PaymentSubscriptionDrop < BaseDrop

  # @return [PaymentSubscription]
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
