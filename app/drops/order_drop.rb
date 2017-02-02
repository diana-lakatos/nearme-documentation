# frozen_string_literal: true
class OrderDrop < BaseDrop
  include CurrencyHelper

  # @return [OrderDrop]
  attr_reader :order

  # @!method id
  #   @return [Integer] numeric identifier for the order
  # @!method user
  #   @return [UserDrop] User owner of the order
  # @!method company
  #   @return [CompanyDrop] Company of the seller user
  # @!method number
  #   @return [String] identifer of the order containing the class name (type of order)
  #     and the numeric identifer of the order
  # @!method line_items
  #   @return [Array<LineItemDrop>] Line items belonging to this order
  # @!method can_host_cancel?
  #   @return [Boolean] whether the host can cancel the order at this stage
  # @!method can_confirm?
  #   @return [Boolean] whether the order can be confirmed at this stage
  # @!method guest_notes
  #   @return [String] guest notes left for the order
  # @!method can_reject?
  #   @return [Boolean] whether the order can be rejected at this stage
  # @!method paid?
  #   @return [Boolean] whether the order has been paid for
  # @!method unconfirmed?
  #   @return [Boolean] whether the order is in the unconfirmed state
  # @!method confirmed?
  #   @return [Boolean] whether the order is in the confirmed state
  # @!method manual_payment?
  #   @return [Boolean] whether the payment for the order is manual
  # @!method can_complete_checkout?
  #   @return [Boolean] whether checkout can be completed for this Order object
  # @!method can_approve_or_decline_checkout?
  #   @return [Boolean] whether checkout can be approved or declined for this Order object
  # @!method has_to_update_credit_card?
  #   @return [Boolean] whether the user needs to update their credit card
  # @!method user_messages
  #   @return [Array<UserMessageDrop>] User messages for discussion between lister and enquirer
  # @!method archived_at
  #   @return [DateTime] Time when the order has been transitioned to archived
  # @!method state
  #   @return [String] state of the current order
  # @!method cancelable?
  #   @return [Boolean] whether the order can be cancelled
  # @!method archived?
  #   @return [Boolean] whether the order has been moved to the archived state
  # @!method penalty_charge_apply?
  #   @return [Boolean] whether the penalty charge applies to this order
  # @!method rejection_reason
  #   @return [String] Reason for the rejection of the order
  # @!method cancellation_policy_hours_for_cancellation
  #   @return [Integer] Hours allowed to cancel without a penalty before the booking starts
  # @!method cancellation_policy_penalty_hours
  #   @return [Integer] Used for calculating the penalty for cancelling (unit_price * cancellation_policy_penalty_hours)
  # @!method created_at
  #   @return [DateTime] time when the order was initiated
  # @!method payment
  #   @return [PaymentDrop] Payment object for this order
  # @!method total_units_text
  #   @return [String] total units as a text (e.g. "2 nights")
  #     the name is taken from the translations 'reservations.item.one' (for singular)
  #     and 'reservations.item.other' (for plural)
  # @!method enquirer_cancelable
  #   @return [Boolean] whether the order is in a state where it can be
  #     cancelled by the enquirer
  # @!method enquirer_editable
  #   @return [Boolean] whether the order is in a state where it can be edited
  #     by the enquirer
  # @!method transactable
  #   @return [TransactableDrop] Transactable object being ordered
  # @!method cancelled_at
  #   @return [DateTime] Time when the order was cancelled
  # @!method confirmed_at
  #   @return [DateTime] Time when the order was confirmed
  # @!method recurring_booking_periods
  #   @return [Array<RecurringBookingPeriodDrop>] Array of recurring booking periods for a recurring booking representing
  #     periods for which a transactable object is bookable/booked
  # @!method creator
  #   @return [UserDrop] Lister user of the item being ordered
  # @!method payment_subscription
  #   @return [PaymentSubscriptionDrop] Payment subscription object for this order
  # @!method confirm_reservations?
  #   @return [Boolean] whether reservations need to be confirmed first
  # @!method bookable?
  #   @return [Boolean] whether the object is bookable (i.e. its type is different from 'Purchase')
  # @!method transactable_pricing
  #   @return [Transactable::PricingDrop] Transactable pricing object for the order
  # @!method inactive?
  #   @return [Boolean] whether the order is inactive (i.e. the initial state when the user just
  #     pressed on 'book'/'buy' without actually completing the order)
  # @!method outbound
  #   @return [DeliveryDrop] outbound delivery for this order (contains information about the
  #     outbound delivery of the items - from the buyer to the seller)
  # @!method inbound
  #   @return [DeliveryDrop] inbound delivery for this order (contains information about the
  #     inbound delivery of the items - from the seller to the buyer)
  # @!method inbound_pickup_date
  #   @return [String] inbound pickup date as a string (date of pickup for the inbound delivery - from
  #     the seller to the buyer)
  # @!method outbound_pickup_date
  #   @return [String] outbound pickup date as a string (date of pickup for the outbound delivery - from
  #     the buyer to the seller)
  # @!method inbound_pickup_address_address
  #   @return [String] inbound pickup address as a string (pickup address for the inbound delivery - from
  #     the seller to the buyer)
  # @!method outbound_return_address_address
  #   @return [String] outbound return address (return address for the outbound delivery - from the
  #     buyer to the seller)
  # @!method quantity
  #   @return [Integer] quantity for this order
  # @!method is_free_booking
  #   @return [Boolean] if order is free
  delegate :id, :user, :company, :number, :line_items, :guest_notes,
           :can_host_cancel?, :can_confirm?, :can_reject?,
           :paid?, :unconfirmed?, :confirmed?, :inactive?, :manual_payment?, :can_complete_checkout?,
           :can_approve_or_decline_checkout?, :has_to_update_credit_card?, :user_messages,
           :archived_at, :state, :cancelable?, :archived?, :penalty_charge_apply?, :rejection_reason,
           :cancellation_policy_hours_for_cancellation, :cancellation_policy_penalty_hours,
           :created_at, :payment, :total_units_text, :enquirer_cancelable, :enquirer_editable,
           :transactable, :cancelled_at, :confirmed_at, :recurring_booking_periods, :creator,
           :payment_subscription, :confirm_reservations?, :bookable?, :transactable_pricing,
           :outbound, :inbound, :inbound_pickup_date, :outbound_pickup_date,
           :inbound_pickup_address_address, :outbound_return_address_address,
           :quantity, :is_free_booking, to: :order

  def initialize(order)
    @source = @order = order.decorate
  end

  # @return [Boolean] whether the payment for this order is manual
  def manual_payment?
    @order.payment.try(:manual_payment?)
  end

  # @return [String] the guest part of the service fee for this particular order
  def service_fee_amount_guest
    @order.service_fee_amount_guest.to_s
  end

  # @return [String] the total amount to be charged for this order
  def total_amount
    @order.total_amount
  end

  # @return [MoneyDrop] total amount to be charged for this order as a MoneyDrop
  def total_amount_money
    @order.total_amount
  end

  # @return [String] the total amount paid for all order items formatted
  #   using the global currency formatting rules
  def total_order_items_amount_formatted
    render_money @order.order_items.paid.map(&:total_amount).sum
  end

  # @return [String] the total amount for this order rendered using
  #   the global currency formatting rules
  def formatted_total_amount
    render_money(@order.total_amount)
  end

  # @return [Boolean] whether or not the order has products with
  #   seller attachments
  # @todo -- depracate DIY @order.line_items.size > 0 ?
  def has_seller_attachments?
    @order.transactable_line_items.each do |line_item|
      return true if line_item.line_item_source.attachments.exists?
    end

    false
  end

  # @return [Boolean] whether the automatic payout setup has been completed
  def possible_payout_not_configured?
    @order.company.possible_payout_not_configured?(@order.payment.payment_gateway)
  end

  # @return [Boolean] whether the current user (host) has not verified their phone number in the context
  #   of an otherwise placeable call with the client
  # @todo -- rething oneliners, extract?
  def show_not_verified_host_alert?
    PlatformContext.current.instance.click_to_call? && @order.transactable.present? && @order.user.communication.try(:verified) && !@context['current_user'].try(:communication).try(:verified)
  end

  # @return [Boolean] whether the current user (client) has not verified their phone number in the
  #   context of an otherwise placeable call with the host
  # @todo -- rething oneliners, extract?
  def show_not_verified_user_alert?
    PlatformContext.current.instance.click_to_call? && @order.transactable && @order.transactable.administrator.communication.try(:verified) && !@context['current_user'].communication.try(:verified)
  end

  # @return [String] the payment state in a humanized format
  # @todo -- try harder :) -- depracate in favor of .state and filter chaining | humanize | capitalize.
  def payment_state
    @order.payment.try(:state).try(:humanize).try(:capitalize)
  end

  # @return [String] the name of the payment method taken from the translations
  #   the translation key is: 'dashboard.host_reservations.payment_methods.[type]'
  #   where type can be: [credit_card nonce express_checkout manual remote free pending]
  # @todo -- This looks like code smell to me
  def translated_payment_method
    I18n.t('dashboard.host_reservations.payment_methods.' + (@order.payment.try(:payment_method).try(:payment_method_type) || 'pending').to_s)
  end

  # @return [ShipmentDrop] first outbound shipment for this order
  # @todo -- depracate in favor of filters
  def outbound_shipment
    @order.deliveries.first
  end

  # @return [ShipmentDrop] first inbound shipment for this order
  # @todo -- depracate in favor of filters
  def inbound_shipment
    @order.deliveries.last
  end

  # @return [Array<LineItemDrop>] array of line items for the order representing shipping charges
  def shipping_line_items
    @order.shipping_line_items
  end

  # @return [String] time to expiration in a human readable format
  #   e.g. '15 minutes'
  # @todo -- this method is formatting time in a specific way -- we shouldnt do that in DIY -- depracate in favor of DateTimeDrop.format or filter with format
  def time_to_expiration
    @order.time_to_expiry(@order.expires_at)
  end

  # @return [Attachable::PaymentDocumentDrop] payment documents for this order
  def payment_documents
    @order.payment_documents.select(&:persisted?)
  end

  # @return [String] penalty fee for this order rendered using the global
  #   currency formatting rules
  def formatted_penalty_fee
    render_money(@order.penalty_fee)
  end

  # @return [Object] returns the order objects for all the other orders the user placed
  #   for the same item
  def all_other_orders
    @order.user.transactable_line_items.where(line_item_source_id: @order.transactable.id).map(&:line_itemable)
  end

  # @return [String] path to creating a new order item (RecurringBookingPeriod) mostly for
  #   tracking time
  # @todo -- depracate in favor of filter
  def new_order_item_path
    routes.new_dashboard_order_order_item_path(@order)
  end

  # @return [String] url to creating a new payment for this order
  # @todo -- depracate in favor of filter
  def new_payment_url
    routes.new_dashboard_company_orders_received_payment_path(order)
  end

  # @return [String] url to cancelling an offer
  # @todo -- depracate in favor of filter
  def offer_cancel_url
    routes.cancel_dashboard_company_orders_received_path(order)
  end

  # @return [String] url to marking the order as completed
  # @todo -- depracate in favor of filter
  def order_complete_url
    routes.complete_dashboard_company_orders_received_path(order)
  end

  # @return [String] path in the application to the rejection form
  #   for an order
  # @todo -- depracate in favor of filter
  def rejection_form_path
    routes.rejection_form_dashboard_company_orders_received_path(order)
  end

  # @return [String] path in the application to creating a new
  #   payment/payment subscription
  # @todo -- depracate in favor of filter
  def confirmation_form_path
    if @order.is_free_booking?
      routes.new_dashboard_company_orders_received_payment_path(order)
    else
      routes.new_dashboard_company_order_payment_subscription_path(order)
    end
  end

  # @return [String] path in the application to confirming this order
  # @todo -- depracate in favor of filter
  def confirm_path
    routes.confirm_dashboard_company_orders_received_path(order)
  end

  # @return [String] path in the application to completing this order
  #   (if it succeeds the order will be moved to the completed state)
  # @todo -- depracate in favor of filter
  def complete_path
    routes.complete_dashboard_company_orders_received_path(order)
  end

  # @return [String] path in the application to cancelling this order
  # @todo -- depracate in favor of filter
  def offer_enquirer_cancel_path
    routes.cancel_dashboard_orders_path(order)
  end

  # @return [Boolean] whether tax is included for the first line item
  #   in the order
  def included_tax?
    @first_line_item =
      first_line_item.included_tax_total_rate.zero? == false
  end

  # @return [Boolean] whether an additional tax rate has been included
  #   with the first line item in the order
  def additional_tax?
    first_line_item.additional_tax_total_rate.zero? == false
  end

  # @return [Array<UserMessageDrop>] user messages for discussing between lister and enquirer
  # @todo - investigate if this can be moved to transactable drop since it is
  def transactable_user_messages
    transactable.user_messages.where('author_id = :user_id OR thread_recipient_id = :user_id', user_id: @order.user_id)
  end

  # @return [Hash] custom properties collection for the order
  def properties
    @order.properties
  end

  # @return [Boolean] whether the order allows drafts; more specifically the order must be an offer and "allow drafts" must
  #   be enabled for the action type in the marketplace admin, and the order must be in the "inactive" (original) status
  # @todo .try much harder ;)
  def allows_draft?
    @order.is_a?(Offer) && @order.try(:transactable).try(:action_type).try(:transactable_type_action_type).try(:allow_drafts) && @order.state == 'inactive'
  end

  # @return [Boolean] whether the order is in the draft state (draft_at present and the actual state is 'inactive')
  def is_draft?
    @order.draft_at.present? && @order.inactive?
  end

  # @return [MoneyDrop] total amount payable to host (subtotal_amount + host_additional_charges + total_tax_amount - service_fee_amount_host)
  def total_payable_to_host
    @order.total_payable_to_host
  end

  # @return [MoneyDrop] amount deducted from the sum that is payable to host (subtotal_amount + host_additional_charges + total_tax_amount)
  def service_fee_amount_host
    @order.service_fee_amount_host
  end

  # @return [MoneyDrop] service_fee_amount_host from which shipping charges have been deducted
  def service_fee_amount_host_without_shipping
    @order.service_fee_amount_host - (@order.shipping_line_items.last&.unit_price || 0)
  end

  # @return [MoneyDrop] the service fee that is added to the base price to yield the final price to be paid
  def service_fee_amount_guest_money
    @order.service_fee_amount_guest
  end

  # @return [MoneyDrop] total_payable_to_host from which shipping charges have been deducted
  def total_payable_to_host_minus_second_shipping
    @order.total_payable_to_host - (@order.shipping_line_items.last&.unit_price || 0)
  end

  # @return [MoneyDrop] total amount for the order plus shipping charges
  def total_amount_plus_shipping
    @order.total_amount + (@order.shipping_line_items.first&.unit_price || 0)
  end

  # @return [MoneyDrop] service_fee_amount_guest minus shipping charges
  def service_fee_amount_guest_money_without_shipping
    @order.service_fee_amount_guest - (@order.shipping_line_items.first&.unit_price || 0)
  end

  # @return [String] current state of the object (e.g. unconfirmed etc.) as a human readable string
  def state_to_string
    @order.state.humanize
  end

  private

  # @return [LineItemDrop] returns the first line item for this order
  #   or a blank (tax items set to 0) OpenStruct if a line item can't be found
  # @todo -- depracate in favor of DIY @order.line_items.first ? or | first (also returning object when there is no line_item seems weird)
  def first_line_item
    @first_line_item ||= @order.line_items.first || OpenStruct.new(included_tax_total_rate: 0, additional_tax_total_rate: 0)
    @first_line_item
  end
end
