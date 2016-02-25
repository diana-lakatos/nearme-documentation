# This class is a connector between subscriber (guest, seller, recurring_booking)
# and payment method. Currently recurring booking is only supported with credit card
# but probably other recurring payment methods will come and PaymentSubscription
# will make it easier to integrate with many subscribers

class PaymentSubscription < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  # subscriber association connects PaymentSubscription with RecurringBooking
  belongs_to :subscriber, polymorphic: true
  belongs_to :instance
  belongs_to :payment_method
  belongs_to :payment_gateway
  belongs_to :credit_card

  accepts_nested_attributes_for :credit_card

  validates_associated :credit_card

  def payment_methods
    payment_gateways = PlatformContext.current.instance.payment_gateways(subscriber.company.iso_country_code, subscriber.currency)
    PaymentMethod.active.credit_card.where(payment_gateway_id: payment_gateways.select {|p| p.supports_recurring_payment? }.map(&:id) )
  end

  def payment_method_id=(payment_method_id)
    self.payment_method = PaymentMethod.find(payment_method_id)
  end

  def payment_method=(payment_method)
    super(payment_method)
    self.payment_gateway = self.payment_method.payment_gateway
    self.test_mode = self.payment_gateway.test_mode?
    # self.merchant_account = self.payment_gateway.merchant_account(company)
  end
end
