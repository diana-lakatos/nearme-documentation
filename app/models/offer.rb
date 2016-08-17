class Offer < Order

  #validates :host_line_items, presence: true
  delegate :action, to: :transactable_pricing

  after_update :activate!, if: :inactive?

  has_many :host_line_items, as: :line_itemable
  has_many :recurring_booking_periods, dependent: :destroy, foreign_key: :order_id
  has_many :order_items, class_name: 'RecurringBookingPeriod', dependent: :destroy, foreign_key: :order_id

  def self.workflow_class
    Offer
  end

  def add_line_item!(attrs)
    transactable = Transactable.find(attrs[:transactable_id])
    transactable_pricing = transactable.action_type.pricings.find(attrs[:transactable_pricing_id])
    transactable_type = transactable.transactable_type

    self.company = transactable.company
    self.creator = transactable.creator
    self.reservation_type = transactable_type.reservation_type
    self.currency = transactable.try(:currency)
    self.additional_charge_ids = attrs[:additional_charge_ids]
    self.is_free_booking = transactable_pricing.is_free_booking

    transactable_line_items.build(
      name: transactable.name,
      transactable_pricing: transactable_pricing,
      quantity: attrs[:quantity] || 1,
      line_item_source: transactable,
      unit_price: transactable_pricing.price,
      line_itemable: self,
      service_fee_guest_percent: transactable_pricing.action.service_fee_guest_percent,
      service_fee_host_percent: transactable_pricing.action.service_fee_host_percent,
    )

    transactable_type.merchant_fees.each do |merchant_fee|
      host_line_items.build(
        name: merchant_fee.name,
        line_item_source: merchant_fee,
        unit_price: merchant_fee.amount,
        line_itemable: self
      )
    end

    # self.skip_checkout_validation = true
    self.save
  end

  def shared_payment_attributes
    {
      payer: transactable.creator,
      company: company,
      company_id: company_id,
      currency: currency,
      total_amount_cents: host_subtotal_amount_cents,
      subtotal_amount_cents: host_subtotal_amount_cents,
      service_fee_amount_guest_cents: service_fee_amount_guest.try(:cents) || 0,
      service_fee_amount_host_cents: service_fee_amount_host.try(:cents) || 0,
      service_additional_charges_cents: service_additional_charges.try(:cents) || 0,
      host_additional_charges_cents: host_additional_charges.try(:cents) || 0,
      cancellation_policy_hours_for_cancellation: cancellation_policy_hours_for_cancellation,
      cancellation_policy_penalty_percentage: cancellation_policy_penalty_percentage,
      payable: self
    }
  end

  monetize :host_subtotal_amount_cents, with_model_currency: :currency
  def host_subtotal_amount_cents
    host_line_items.map(&:total_price_cents).sum
  end

  def transactable
    transactables.first
  end

  def transactable_pricing
    transactable_line_items.first.transactable_pricing
  end

  def charge_and_confirm!
    if (payment_subscription.present? || (payment.authorize && payment.capture!)) && confirm!
      transactable.start!
      reject_related_offers!
      disable_transactable!

      true
    end
  end

  def disable_transactable!
    transactable.disable!
  end

  def reject_related_offers!
    related_offers = Offer.unconfirmed.
      joins("INNER JOIN line_items ON line_items.line_itemable_id = orders.id AND line_items.line_itemable_type = 'Offer'").
      where("line_items.line_item_source_type = 'Transactable' AND line_items.line_item_source_id = ?", transactable.id).where.not(id: self.id)

    related_offers.each do |offer|
      offer.reject!
    end
  end

  def with_payment?
    false
  end

  def with_payment_subscription?
    false
  end

  def all_paid?
    recurring_booking_periods.all?(&:paid_at)
  end

  def activate_order!
    WorkflowStepJob.perform(WorkflowStep::OfferWorkflow::CreatedWithoutAutoConfirmation, self.id)
  end

  def cancelable?
    true
  end

  def can_reject?
    state == 'unconfirmed'
  end

  def enquirer_cancelable
    state == 'unconfirmed'
  end
  alias :enquirer_cancelable? :enquirer_cancelable

  def enquirer_editable
    state.in? ['unconfirmed', 'inactive']
  end
  alias :enquirer_editable? :enquirer_editable

  def to_liquid
    @offer_drop ||= OfferDrop.new(self)
  end
end
