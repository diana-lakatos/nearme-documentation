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
  belongs_to :credit_card, -> { with_deleted }

  attr_accessor :chosen_credit_card_id

  accepts_nested_attributes_for :credit_card

  validates_associated :credit_card

  before_validation do |p|
    self.credit_card_id ||= subscriber.instance_clients.find_by(payment_gateway: payment_gateway.id).credit_cards.find(p.chosen_credit_card_id).try(:id) if subscriber.respond_to?(:instance_clients) && p.chosen_credit_card_id.present? &&  p.chosen_credit_card_id != 'custom'
    true
  end

  def payment_methods
    if payment_method
      [payment_method]
    else
      fetch_payment_methods
    end
  end

  def fetch_payment_methods
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
  end

  def credit_card_attributes=(cc_attrs)
    super(cc_attrs.merge(
        payment_gateway: self.payment_gateway,
        client: self.subscriber.client
      )
    )
  end
end
