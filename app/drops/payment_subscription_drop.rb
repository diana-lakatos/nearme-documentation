class PaymentSubscriptionDrop < BaseDrop

  attr_reader :payment_subscription

  delegate :id, :expired?, to: :payment_subscription

  def initialize(payment_subscription)
    @payment_subscription = payment_subscription
  end

end
