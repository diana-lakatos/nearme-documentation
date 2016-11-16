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
  belongs_to :payer, class_name: 'User'
  belongs_to :company, -> { with_deleted }

  attr_accessor :chosen_credit_card_id

  accepts_nested_attributes_for :credit_card

  validates_associated :credit_card
  validates :credit_card, presence: true, if: proc { |p| p.new_record? }
  validates :payer, presence: true

  before_validation do |p|
    self.payer ||= subscriber.try(:owner)
    if p.payment_method.try(:payment_method_type) == 'credit_card' && payer.respond_to?(:instance_clients) && p.chosen_credit_card_id.present? && p.chosen_credit_card_id != 'custom'
      self.credit_card_id ||= payer.instance_clients.find_by(payment_gateway: payment_gateway.id, test_mode: test_mode?).try(:credit_cards).try(:find, p.chosen_credit_card_id).try(:id)
    end
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
    ids = if payment_method
            [payment_method]
          else
            fetch_payment_methods
    end.flatten.uniq.map(&:id)

    PaymentMethod.where(id: ids)
  end

  def fetch_payment_methods
    payment_gateways = PlatformContext.current.instance.payment_gateways(iso_country_code, currency)
    PaymentMethod.active.credit_card.where(payment_gateway_id: payment_gateways.select(&:supports_recurring_payment?).map(&:id))
  end

  def payment_method_id=(payment_method_id)
    self.payment_method = PaymentMethod.find(payment_method_id)
  end

  def payment_method=(payment_method)
    super(payment_method)
    self.payment_gateway = self.payment_method.payment_gateway
    self.test_mode = payment_gateway.test_mode?
  end

  def credit_card_attributes=(cc_attrs)
    super(cc_attrs.merge(
      payment_gateway: payment_gateway,
      test_mode: test_mode?,
      client: self.payer || subscriber.user
    )
    )
  end

  def to_liquid
    @payment_subscription_drop ||= PaymentSubscriptionDrop.new(self)
  end
end
