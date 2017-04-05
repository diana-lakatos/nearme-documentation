# frozen_string_literal: true
class CheckoutShoppingCart
  attr_reader :shopping_cart
  attr_accessor :payment
  delegate :new_record?, :persisted?, to: :shopping_cart

  def initialize(shopping_cart)
    @shopping_cart = shopping_cart
    @payment = Payment.new
  end

  def save
    @payment_object_tree_builder = PaymentObjectTreeBuilder.new(@payment)
    @shopping_cart.orders.each do |o|
      @payment_object_tree_builder.build(o)
      raise PaymentProcessingError, "Can't process order #{o.id} (#{o.class.name})" unless o.process!
    end
    @shopping_cart.checkout_at = Time.zone.now
    @shopping_cart.save!
  end

  class Payment
    attr_accessor :credit_card_token, :payment_method_id
    def persisted?
      false
    end

    def payment_method
      @payment_method ||= PaymentMethod.find(payment_method_id)
    end

    def save
      true
    end
  end

  class PaymentObjectTreeBuilder
    def initialize(payment)
      @payment = payment
    end

    def build(order)
      order.build_payment({
        payer: order.user,
        payment_method: @payment.payment_method,
        credit_card: CreditCard.new(credit_card_token: @payment.credit_card_token,
                                    payment_method: @payment.payment_method,
                                    payer: order.user)
      }.reverse_merge(order.shared_payment_attributes))
    end
  end
  class PaymentProcessingError < StandardError
  end
end
