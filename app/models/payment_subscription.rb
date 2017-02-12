# frozen_string_literal: true
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
  belongs_to :payer, class_name: 'User'
  belongs_to :company, -> { with_deleted }
  belongs_to :payment_source, polymorphic: true

  attr_accessor :chosen_credit_card_id

  accepts_nested_attributes_for :payment_source

  validates_associated :payment_source
  validates :payment_source, presence: true, if: proc { |p| p.new_record? && !p.payment_method.manual? }
  validates :payer, presence: true

  def payment_source_attributes=(source_attributes)
    return unless payment_method.respond_to?(:payment_sources)

    source = self.payment_source || payment_method.payment_sources.new
    source.attributes = source_attributes.merge({ payment_method: payment_method, payer: payer })
    self.payment_source = source
  end
  alias credit_card_attributes= payment_source_attributes=
  alias credit_card= payment_source=

  def credit_card
    self.payment_source if self.payment_source_type == 'CreditCard'
  end

  def bank_account
    self.payment_source if self.payment_source_type == 'BankAccount'
  end

  def can_activate?
    payment_source.try(:can_activate?)
  end

  def process!
    return false unless valid?
    return true if payment_method.try(:manual?)
    return false if payment_source.blank?
    return false unless payment_source.process!

    true
  end

  # @return [Boolean] whether the payment subscription has expired
  def expired?
    !expired_at.nil?
  end

  def expire!
    touch(:expired_at)
  end

  def unexpire!
    update_attribute(:expired_at, nil)
  end

  def currency
    @currency ||= subscriber.currency_object.iso_code
  end

  def iso_country_code
    @iso_country_code ||= company.iso_country_code
  end

  def payment_methods
    ids = fetch_payment_methods.compact.flatten.uniq.map(&:id)

    PaymentMethod.recurring.where(id: ids)
  end

  def fetch_payment_methods
    payment_gateways = PlatformContext.current.instance.payment_gateways(iso_country_code, currency)
    PaymentMethod.active.recurring.where(payment_gateway_id: payment_gateways.select(&:supports_payment_source_store?).map(&:id))
  end

  def payment_method_id=(payment_method_id)
    self.payment_method = PaymentMethod.find(payment_method_id)
  end

  def payment_method=(payment_method)
    super(payment_method)
    self.payment_gateway = self.payment_method.payment_gateway
    self.test_mode = payment_gateway.test_mode?
  end

  def to_liquid
    @payment_subscription_drop ||= PaymentSubscriptionDrop.new(self)
  end
end
