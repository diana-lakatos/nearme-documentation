# frozen_string_literal: true
class Offer < Order
  has_many :host_line_items, as: :line_itemable
  has_many :recurring_booking_periods, dependent: :destroy, foreign_key: :order_id

  delegate :action, to: :transactable_pricing
  before_update :set_draft_at

  def try_to_activate!
    return true unless inactive? && valid? && checkout_completed?
    return true if draft_at?

    activate!
  end

  def complete!
    if can_complete?
      archive!

      touch(:archived_at)
    else
      false
    end
  end

  def can_complete?
    !order_items.pending.any?
  end

  def self.workflow_class
    Offer
  end

  def overdue
    # Offer currently doesn't go into overdue state
    # we simply ask to add new credit card
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
    self.is_free_booking = transactable_pricing.is_free_booking?

    transactable_line_items.build(
      name: transactable.name,
      transactable_pricing: transactable_pricing,
      quantity: attrs[:quantity] || 1,
      line_item_source: transactable,
      unit_price: transactable_pricing.price,
      line_itemable: self,
      service_fee_guest_percent: transactable_pricing.action.service_fee_guest_percent,
      service_fee_host_percent: transactable_pricing.action.service_fee_host_percent,
      minimum_lister_service_fee_cents: transactable_pricing.action.minimum_lister_service_fee_cents
    )

    transactable_type.merchant_fees.each do |merchant_fee|
      host_line_items.build(
        name: merchant_fee.name,
        line_item_source: merchant_fee,
        unit_price: merchant_fee.amount,
        line_itemable: self
      )
    end

    save
  end

  def payer
   transactable.creator
  end

  monetize :unit_price_cents, with_model_currency: :currency
  def unit_price_cents
    transactable_line_items.map(&:total_price_cents).sum + host_line_items.map(&:total_price_cents).sum
  end

  def transactable
    transactables.first
  end

  def transactable_pricing
    transactable_line_items.first.transactable_pricing
  end

  def charge_and_confirm!
    return true if confirmed?

    if (payment_subscription.present? || (payment.authorize && payment.capture!)) && confirm!
      create_payment_subscription! if payment_subscription.blank?
      transactable.start!
      reject_related_offers!
      withdraw_invitations!
      WorkflowStepJob.perform(WorkflowStep::OfferWorkflow::ManuallyConfirmed, id)

      true
    end
  end

  def create_payment_subscription!
    create_payment_subscription(credit_card_id: payment.credit_card_id,
                                payment_method_id: payment.payment_method_id,
                                payment_gateway_id: payment.payment_gateway_id,
                                company_id: payment.company_id,
                                test_mode: payment.payment_gateway_mode == PaymentGateway::TEST_MODE,
                                payer_id: payment.payer_id)
  end

  def disable_transactable!
    transactable.disable!
  end

  def withdraw_invitations!
    transactable.transactable_collaborators.where.not(user: user).destroy_all
  end

  def reject_related_offers!
    related_offers = Offer.unconfirmed
                          .joins("INNER JOIN line_items ON line_items.line_itemable_id = orders.id AND line_items.line_itemable_type = 'Offer'")
                          .where("line_items.line_item_source_type = 'Transactable' AND line_items.line_item_source_id = ?", transactable.id).where.not(id: id)

    related_offers.each(&:reject!)
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
    WorkflowStepJob.perform(WorkflowStep::OfferWorkflow::CreatedWithoutAutoConfirmation, id)
  end

  def cancelable?
    true
  end

  def schedule_refund
    true
  end

  def can_reject?
    state == 'unconfirmed'
  end

  def reject(reason = nil)
    if reservation_type.withdraw_invitation_when_reject?
      user.transactable_collaborators.where(transactable: transactable).destroy_all
    end
    super
  end

  def enquirer_cancelable
    draft_at? || (state == 'unconfirmed')
  end
  alias enquirer_cancelable? enquirer_cancelable

  def enquirer_editable
    editable_states = %w(inactive)
    editable_states << 'unconfirmed' if reservation_type.edit_unconfirmed
    state.in? editable_states || draft_at?
  end
  alias enquirer_editable? enquirer_editable

  def to_liquid
    @offer_drop ||= OfferDrop.new(self)
  end

  def set_draft_at
    self.draft_at = (Time.current if save_draft)

    true
  end
end
