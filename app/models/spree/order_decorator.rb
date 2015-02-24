Spree::Order.class_eval do
  include Spree::Scoper

  belongs_to :company
  belongs_to :instance
  belongs_to :partner
  belongs_to :platform_context_detail, :polymorphic => true

  attr_accessor :card_number, :card_code, :card_expires, :card_holder_first_name, :card_holder_last_name
  scope :completed, -> { where(state: 'complete') }

  has_one :billing_authorization, as: :reference
  has_many :near_me_payments, as: :payable, class_name: '::Payment'
  has_many :shipping_methods, class_name: 'Spree::ShippingMethod'
  has_many :additional_charges, as: :target
  has_many :payment_documents, as: :attachable, class_name: 'Attachable::PaymentDocument', dependent: :destroy

  accepts_nested_attributes_for :additional_charges
  accepts_nested_attributes_for :payment_documents

  after_save :purchase_shippo_rate
  before_create :store_platform_context_detail

  alias_method :old_finalize!, :finalize!

  self.per_page = 5

  # We do not need spree to verify customer email
  # hence to avoid Spree::Order email validations errors
  # email validation is removed
  _validate_callbacks.each do |callback|
    callback.raw_filter.attributes.delete(:email) if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
    callback.raw_filter.attributes.delete(:email) if callback.raw_filter.is_a?(EmailValidator)
  end

  def finalize!
    old_finalize!
    deliver_notify_seller_email
  end

  def deliver_notify_seller_email
    Spree::OrderMailer.notify_seller_email(self.id).deliver
  end

  def total_amount_to_charge
    monetize(self.total) + service_fee_amount_guest
  end

  def total_amount_without_fee
    monetize(self.total)
  end

  def subtotal_amount_to_charge
    monetize(self.item_total)
  end

  def service_fee_amount_guest
    service_fee_calculator.service_fee_guest
  end

  def service_fee_guest_without_charges
    service_fee_calculator.service_fee_guest_wo_ac
  end

  def service_fee_amount_host
    service_fee_calculator.service_fee_guest.cents
  end

  def service_fee_calculator
    options = {
      guest_fee_percent:  instance.service_fee_guest_percent,
      host_fee_percent:   instance.service_fee_host_percent,
      additional_charges: additional_charges
    }
    @service_fee_calculator ||= Payment::ServiceFeeCalculator.new(subtotal_amount_to_charge, options)
  end

  def monetize(amount)
    Money.new(amount*Money::Currency.new(self.currency).subunit_to_unit, currency)
  end

  # hackish hacky hack
  def owner
    user
  end

  def purchase_shippo_rate
    if self.state_changed? && self.state == 'complete'
      shippo_shipping_method = self.shipping_methods.joins(:shipping_rates).merge(Spree::ShippingRate.only_selected).readonly(false).first
      if shippo_shipping_method.present?
        ShippoPurchaseRateJob.perform(shippo_shipping_method)
      end
    end

    true
  end

  def store_platform_context_detail
    self.platform_context_detail_type = PlatformContext.current.platform_context_detail.class.to_s
    self.platform_context_detail_id = PlatformContext.current.platform_context_detail.id
  end
end

