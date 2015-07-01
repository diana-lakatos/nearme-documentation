Spree::Order.class_eval do
  include Spree::Scoper

  belongs_to :company
  belongs_to :instance
  belongs_to :partner
  belongs_to :platform_context_detail, :polymorphic => true

  attr_accessor :card_number, :card_code, :card_exp_month, :card_exp_year, :card_holder_first_name, :card_holder_last_name
  scope :completed, -> { where(state: 'complete') }
  scope :approved, -> { where.not(approved_at: nil) }
  scope :paid, -> { where(payment_state: 'paid') }
  scope :shipped, -> { where(shipment_state: 'shipped') }
  scope :reviewable, -> { completed.approved.paid.shipped }

  has_one :billing_authorization, -> { where(success: true) }, as: :reference
  has_many :billing_authorizations, as: :reference
  has_many :near_me_payments, as: :payable, class_name: '::Payment'
  has_many :shipping_methods, class_name: 'Spree::ShippingMethod'
  has_many :additional_charges, as: :target
  has_many :payment_documents, as: :attachable, class_name: 'Attachable::PaymentDocument', dependent: :destroy

  accepts_nested_attributes_for :additional_charges
  accepts_nested_attributes_for :payment_documents

  after_save :purchase_shippo_rate
  before_create :store_platform_context_detail
  before_update :reject_empty_documents


  self.per_page = 5

  # We do not need spree to verify customer email
  # hence to avoid Spree::Order email validations errors
  # email validation is removed
  _validate_callbacks.each do |callback|
    callback.raw_filter.attributes.delete(:email) if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
    callback.raw_filter.attributes.delete(:email) if callback.raw_filter.is_a?(EmailValidator)
  end

  PAYMENT_METHODS = {
    :credit_card => 'credit_card',
    :nonce       => 'nonce',
    :manual      => 'manual',
  }

  validates_inclusion_of :payment_method, in: PAYMENT_METHODS.values, allow_nil: true

  def checkout_extra_fields(attributes = {})
    @checkout_extra_fields ||= CheckoutExtraFields.new(self.user, attributes)
  end

  def credit_card_payment?
    payment_method == Reservation::PAYMENT_METHODS[:credit_card]
  end

  def manual_payment?
    payment_method == Reservation::PAYMENT_METHODS[:manual]
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
    Money.new(service_fee_calculator.service_fee_host.cents, currency)
  end

  def service_fee_calculator
    options = {
      guest_fee_percent:  (manual_payment? ? 0 : instance.service_fee_guest_percent),
      host_fee_percent:   (manual_payment? ? 0 : instance.service_fee_host_percent),
      additional_charges: additional_charges
    }
    @service_fee_calculator ||= Payment::ServiceFeeCalculator.new(subtotal_amount_to_charge, options)
  end

  def monetize(amount)
    Money.new(amount*Money::Currency.new(self.currency).subunit_to_unit, currency)
  end

  def reviewable?
    completed? && approved_at.present? && paid? && shipped?
  end

  def paid?
    payment_state == 'paid'
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

  def reject_empty_documents
    if self.state == "complete"
      self.payment_documents = self.payment_documents.reject { |document| document.file.blank? }
    end
  end

  def possible_manual_payment?
    instance.possible_manual_payment?
  end

  # Finalizes an in progress order after checkout is complete.
  # Called after transition to complete state when payments will have been processed
  def finalize!
    # lock all adjustments (coupon promotions, etc.)
    all_adjustments.each{|a| a.close}

    # update payment and shipment(s) states, and save
    updater.update_payment_state
    shipments.each do |shipment|
      shipment.update!(self)
      shipment.finalize!
    end

    updater.update_shipment_state
    save!
    updater.run_hooks

    touch :completed_at

    WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Finalized, id)

    consider_risk
  end

  def after_cancel
    shipments.each { |shipment| shipment.cancel! }
    payments.completed.each { |payment| payment.cancel! }
    WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Cancelled, id)
    self.update!
  end

  def to_liquid
    Spree::OrderDrop.new(self)
  end

end


