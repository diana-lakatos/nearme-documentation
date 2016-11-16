# frozen_string_literal: true
class OrderDrop < BaseDrop
  include CurrencyHelper

  attr_reader :order

  # id
  #   numeric identifier for this order
  # user
  #   user object representing the user who has placed this order
  # company
  #   company object to which the ordering user belongs
  # number
  #   string representing the unique identifier for this order
  # line_items
  #   an array of line items that belong to this order in the form of LineItem objects
  delegate :id, :user, :company, :number, :line_items, :line_item_adjustments,
           :shipping_profile, :adjustment, :can_host_cancel?, :can_confirm?, :can_reject?,
           :paid?, :unconfirmed?, :confirmed?, :inactive?, :manual_payment?, :can_complete_checkout?,
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

  def manual_payment?
    @order.payment.try(:manual_payment?)
  end

  # the guest part of the service fee for this particular order
  def service_fee_amount_guest
    @order.service_fee_amount_guest.to_s
  end

  # the total amount to be charged for this order
  def total_amount
    @order.total_amount.to_s
  end

  def total_amount_money
    @order.total_amount
  end

  # the total amount of all order items
  def total_order_items_amount_formatted
    render_money @order.order_items.paid.map(&:total_amount).sum
  end

  def formatted_total_amount
    render_money(@order.total_amount)
  end

  # whether or not the order has products with seller attachments
  def has_seller_attachments?
    @order.transactable_line_items.each do |line_item|
      return true if line_item.line_item_source.attachments.exists?
    end

    false
  end

  def possible_payout_not_configured?
    @order.company.possible_payout_not_configured?(@order.payment.payment_gateway)
  end

  def show_not_verified_host_alert?
    PlatformContext.current.instance.click_to_call? && @order.transactable.present? && @order.user.communication.try(:verified) && !@context['current_user'].try(:communication).try(:verified)
  end

  def show_not_verified_user_alert?
    PlatformContext.current.instance.click_to_call? && @order.transactable && @order.transactable.administrator.communication.try(:verified) && !@context['current_user'].communication.try(:verified)
  end

  def payment_state
    @order.payment.try(:state).try(:humanize).try(:capitalize)
  end

  def translated_payment_method
    I18n.t('dashboard.host_reservations.payment_methods.' + (@order.payment.try(:payment_method).try(:payment_method_type) || 'pending').to_s)
  end

  def outbound_shipment
    @order.deliveries.first
  end

  def inbound_shipment
    @order.deliveries.last
  end

  def shipping_line_items
    @order.shipping_line_items
  end

  def time_to_expiration
    @order.time_to_expiry(@order.expires_at)
  end

  def payment_documents
    @order.payment_documents.select(&:persisted?)
  end

  def formatted_penalty_fee
    render_money(@order.penalty_fee)
  end

  def all_other_orders
    @order.user.transactable_line_items.where(line_item_source_id: @order.transactable.id).map(&:line_itemable)
  end

  def new_order_item_path
    routes.new_dashboard_order_order_item_path(@order)
  end

  def new_payment_url
    routes.new_dashboard_company_orders_received_payment_path(order)
  end

  def offer_cancel_url
    routes.cancel_dashboard_company_orders_received_path(order)
  end

  def order_complete_url
    routes.complete_dashboard_company_orders_received_path(order)
  end

  def rejection_form_path
    routes.rejection_form_dashboard_company_orders_received_path(order)
  end

  def confirmation_form_path
    if @order.is_free_booking?
      routes.new_dashboard_company_orders_received_payment_path(order)
    else
      routes.new_dashboard_company_order_payment_subscription_path(order)
    end
  end

  def confirm_path
    routes.confirm_dashboard_company_orders_received_path(order)
  end

  def offer_enquirer_cancel_path
    routes.cancel_dashboard_orders_path(order)
  end

  def included_tax?
    @first_line_item =
      first_line_item.included_tax_total_rate.zero? == false
  end

  def additional_tax?
    first_line_item.additional_tax_total_rate.zero? == false
  end

  def transactable_user_messages
    transactable.user_messages.where('author_id = :user_id OR thread_recipient_id = :user_id', user_id: @order.user_id)
  end

  def properties
    @order.properties
  end

  def allows_draft?
    @order.is_a?(Offer) && @order.try(:transactable).try(:action_type).try(:transactable_type_action_type).try(:allow_drafts) && @order.state == 'inactive'
  end

  def is_draft?
    @order.draft_at.present? && @order.inactive?
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

  def first_line_item
    @first_line_item ||= @order.line_items.first || OpenStruct.new(included_tax_total_rate: 0, additional_tax_total_rate: 0)
    @first_line_item
  end
end
