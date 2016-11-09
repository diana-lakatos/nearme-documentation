# frozen_string_literal: true
class OrderDrop < BaseDrop
  include CurrencyHelper

  # @return [Order]
  attr_reader :order

  # @!method id
  #   @return [Integer] numeric identifier for the order
  # @!method user
  #   User owner of the order
  #   @return (see Order#user)
  # @!method company
  #   Company of the seller user
  #   @return (see Order#company)
  # @!method number
  #   @return (see Order#number)
  # @!method line_items
  #   Line items belonging to this order
  #   @return (see Order#line_items)
  # @!method can_host_cancel?
  #   @return [Boolean] whether the host can cancel the order at this stage
  # @!method can_confirm?
  #   @return [Boolean] whether the order can be confirmed at this stage
  # @!method can_reject?
  #   @return [Boolean] whether the order can be rejected at this stage
  # @!method paid?
  #   @return (see Order#paid?)
  # @!method unconfirmed?
  #   @return [Boolean] whether the order is in the unconfirmed state
  # @!method confirmed?
  #   @return [Boolean] whether the order is in the confirmed state
  # @!method manual_payment?
  #   @return [Boolean] whether the payment for the order is manual
  # @!method can_complete_checkout?
  #   @return (see Order#can_complete_checkout?)
  # @!method can_approve_or_decline_checkout?
  #   @return (see Order#can_approve_or_decline_checkout?)
  # @!method has_to_update_credit_card?
  #   @return (see Order#has_to_update_credit_card?)
  # @!method user_messages
  #   User messages for discussion between lister and enquirer
  #   @return (see Order#user_messages)
  # @!method archived_at
  #   Time when the order has been transitioned to archived
  #   @return (see Order#archived_at)
  # @!method state
  #   @return [String] state of the current order
  # @!method cancelable?
  #   @return (see Order#cancelable?)
  # @!method archived?
  #   @return (see Order#archived?)
  # @!method penalty_charge_apply?
  #   @return (see Order#penalty_charge_apply?)
  # @!method rejection_reason
  #   Reason for the rejection of the order
  #   @return (see Order#rejection_reason)
  # @!method cancellation_policy_hours_for_cancellation
  #   Hours allowed to cancel without a penalty before the booking starts
  #   @return (see Order#cancellation_policy_hours_for_cancellation
  # @!method cancellation_policy_penalty_hours
  #   Used for calculating the penalty for cancelling (unit_price * cancellation_policy_penalty_hours)
  #   @return (see Order#cancellation_policy_penalty_hours)
  # @!method created_at
  #   @return [ActiveSupport::TimeWithZone] time when the order was initiated
  # @!method payment
  #   Payment object for this order
  #   @return (see Order#payment)
  # @!method total_units_text
  #   @return (see OrderDecorator#total_units_text)
  # @!method enquirer_cancelable
  #   @return (see Order#enquirer_cancelable)
  # @!method enquirer_editable
  #   @return (see Order#enquirer_editable)
  # @!method transactable
  #   Transactable object being ordered
  #   @return (see Order#transactable)
  # @!method cancelled_at
  #   Time when the order was cancelled
  #   @return (see Order#cancelled_at)
  # @!method confirmed_at
  #   Time when the order was confirmed
  #   @return (see Order#confirmed_at)
  # @!method recurring_booking_periods
  #   Array of recurring booking periods for a recurring booking representing
  #     periods for which a transactable object is bookable/booked
  #   @return (see RecurringBooking#recurring_booking_periods)
  # @!method creator
  #   Lister user of the item being ordered
  #   @return (see Order#creator)
  # @!method payment_subscription
  #   Payment subscription object for this order
  #   @return [PaymentSubscription]
  # @!method confirm_reservations?
  #   @return (see Order#confirm_reservations?)
  # @!method bookable?
  #   @return (see Order#bookable?)
  # @!method transactable_pricing
  #   Transactable pricing object for the order
  #   @return (see Order#transactable_pricing)
  # @todo Investigate missing line_item_adjustments
  # @todo Investigate missing shipping_profile
  # @todo Investigate missing adjustment
  delegate :id, :user, :company, :number, :line_items, :line_item_adjustments,
           :shipping_profile, :adjustment, :can_host_cancel?, :can_confirm?, :can_reject?,
           :paid?, :unconfirmed?, :confirmed?, :manual_payment?, :can_complete_checkout?,
           :can_approve_or_decline_checkout?, :has_to_update_credit_card?, :user_messages,
           :archived_at, :state, :cancelable?, :archived?, :penalty_charge_apply?, :rejection_reason,
           :cancellation_policy_hours_for_cancellation, :cancellation_policy_penalty_hours,
           :created_at, :payment, :total_units_text, :enquirer_cancelable, :enquirer_editable,
           :transactable, :cancelled_at, :confirmed_at, :recurring_booking_periods, :creator,
           :payment_subscription, :confirm_reservations?, :bookable?, :transactable_pricing,
           :outbound, :inbound, :inbound_pickup_date, :outbound_pickup_date,
           :inbound_pickup_address_address, :outbound_return_address_address,
           to: :order

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
    @order.total_amount.to_s
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
  def show_not_verified_host_alert?
    PlatformContext.current.instance.click_to_call? && @order.transactable.present? && @order.user.communication.try(:verified) && !@context['current_user'].try(:communication).try(:verified)
  end

  # @return [Boolean] whether the current user (client) has not verified their phone number in the
  #   context of an otherwise placeable call with the host
  def show_not_verified_user_alert?
    PlatformContext.current.instance.click_to_call? && @order.transactable && @order.transactable.administrator.communication.try(:verified) && !@context['current_user'].communication.try(:verified)
  end

  # @return [String] the payment state in a humanized format
  def payment_state
    @order.payment.try(:state).try(:humanize).try(:capitalize)
  end

  # @return [String] the name of the payment method taken from the translations
  #   the translation key is: 'dashboard.host_reservations.payment_methods.[type]'
  #   where type can be: [credit_card nonce express_checkout manual remote free pending]
  def translated_payment_method
    I18n.t('dashboard.host_reservations.payment_methods.' + (@order.payment.try(:payment_method).try(:payment_method_type) || 'pending').to_s)
  end

  # @return [Shipment] first outbound shipment for this order
  def outbound_shipment
    @order.deliveries.first
  end

  # @return [Shipment] first inbound shipment for this order
  def inbound_shipment
    @order.deliveries.last
  end

  def shipping_line_items
    @order.shipping_line_items
  end

  # @return [String] time to expiration in a human readable format
  #   e.g. '15 minutes'
  def time_to_expiration
    @order.time_to_expiry(@order.expires_at)
  end

  # @return [Attachable::PaymentDocument] payment documents for this order
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
  def new_order_item_path
    routes.new_dashboard_order_order_item_path(@order)
  end

  # @return [String] url to creating a new payment for this order
  # @todo Path/url inconsistency
  def new_payment_url
    routes.new_dashboard_company_orders_received_payment_path(order)
  end

  # @return [String] url to cancelling an offer
  # @todo Path/url inconsistency
  def offer_cancel_url
    routes.cancel_dashboard_company_orders_received_path(order)
  end

  # @return [String] path in the application to the rejection form
  #   for an order
  def rejection_form_path
    routes.rejection_form_dashboard_company_orders_received_path(order)
  end

  # @return [String] path in the application to creating a new 
  #   payment/payment subscription
  def confirmation_form_path
    if @order.is_free_booking?
      routes.new_dashboard_company_orders_received_payment_path(order)
    else
      routes.new_dashboard_company_order_payment_subscription_path(order)
    end
  end

  # @return [String] path in the application to confirming this order
  def confirm_path
    routes.confirm_dashboard_company_orders_received_path(order)
  end

  # @return [String] path in the application to completing this order
  #   (if it succeeds the order will be moved to the completed state)
  def complete_path
    routes.complete_dashboard_company_orders_received_path(order)
  end

  # @return [String] path in the application to cancelling this order
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

  # @return [Array<UserMessage>] user messages for discussing between lister and enquirer
  def transactable_user_messages
    transactable.user_messages.where('author_id = :user_id OR thread_recipient_id = :user_id', user_id: @order.user_id)
  end

  # @return [CustomAttributes::CollectionProxy] custom properties collection for the order
  def properties
    @order.properties
  end

  def total_payable_to_host
    @order.total_payable_to_host
  end

  def service_fee_amount_host
    @order.service_fee_amount_host
  end

  def service_fee_amount_host_without_shipping
    @order.service_fee_amount_host - (@order.shipping_line_items.last&.unit_price || 0)
  end

  def service_fee_amount_guest_money
    @order.service_fee_amount_guest
  end

  def total_payable_to_host_minus_second_shipping
    @order.total_payable_to_host - (@order.shipping_line_items.last&.unit_price || 0)
  end

  def total_amount_plus_shipping
    @order.total_amount + (@order.shipping_line_items.first&.unit_price || 0)
  end

  def service_fee_amount_guest_money_without_shipping
    @order.service_fee_amount_guest - (@order.shipping_line_items.first&.unit_price || 0)
  end

  private

  # @return [LineItem, OpenStruct] returns the first line item for this order
  #   or a blank (tax items set to 0) OpenStruct if a line item can't be found
  def first_line_item
    @first_line_item ||= @order.line_items.first || OpenStruct.new(included_tax_total_rate: 0, additional_tax_total_rate: 0)
    @first_line_item
  end
end
