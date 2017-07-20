# frozen_string_literal: true
class Order < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end

  ORDER_TYPES = %w(Reservation RecurringBooking Purchase DelayedReservation Offer).freeze
  STATES = %w(unconfirmed confirmed overdued archived not_archived).freeze

  DEFAULT_DASHBOARD_TABS = %w(unconfirmed confirmed archived).freeze

  include Encryptable
  include Modelable
  include Payable
  include ShippoLegacy::Order
  include Shippings::Order
  include Validatable
  include PaypalExpressOrder
  include CustomizationsOwnerable

  attr_accessor :skip_checkout_validation, :delivery_ids, :checkout_update, :save_draft, :cancel_draft
  attr_reader :external_redirect

  store_accessor :settings, :validate_on_adding_to_cart, :skip_payment_authorization

  has_custom_attributes target_type: 'ReservationType', target_id: :reservation_type_id

  belongs_to :administrator, -> { with_deleted }, class_name: 'User'
  belongs_to :billing_address, foreign_key: :billing_address_id, class_name: 'OrderAddress'
  belongs_to :company, -> { with_deleted }
  # TODO: creator is not intuitive name we should switch to the "lister"
  belongs_to :creator, -> { with_deleted }, class_name: 'User'
  belongs_to :currency_object, foreign_key: :currency, primary_key: :iso_code, class_name: 'Currency'
  belongs_to :owner, -> { with_deleted }, class_name: 'User', counter_cache: true
  belongs_to :reservation_type
  belongs_to :shipping_address, foreign_key: :shipping_address_id, class_name: 'OrderAddress'
  belongs_to :shopping_cart, -> { with_deleted }
  belongs_to :transactable, -> { with_deleted }
  belongs_to :transactable_pricing, -> { with_deleted }, class_name: 'Transactable::Pricing'
  belongs_to :user, -> { with_deleted }

  has_many :payment_documents, as: :attachable, class_name: 'Attachable::PaymentDocument', dependent: :destroy
  has_many :reviews, as: :reviewable
  has_many :user_messages, as: :thread_context
  has_many :periods, class_name: '::ReservationPeriod', dependent: :destroy, foreign_key: 'reservation_id', inverse_of: :reservation
  has_many :waiver_agreements, as: :target
  has_many :transactables, through: :transactable_line_items, source: :line_item_source, source_type: 'Transactable'
  has_many :order_items, class_name: 'RecurringBookingPeriod', dependent: :destroy, foreign_key: :order_id
  has_many :cancellation_policies, as: :cancellable

  accepts_nested_attributes_for :order_items
  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :payment_documents
  accepts_nested_attributes_for :shipping_address
  accepts_nested_attributes_for :waiver_agreements, allow_destroy: true
  accepts_nested_attributes_for :customizations, allow_destroy: true
  accepts_nested_attributes_for :payment_subscription
  accepts_nested_attributes_for :transactable

  validates :user, presence: true
  validates :currency, presence: true
  validate :validate_acceptance_of_waiver_agreements, on: :update, if: -> { should_validate_field?('reservation', 'waiver_agreements') }
  validates :rejection_reason, length: { maximum: 1500 }

  before_validation :remove_empty_documents
  before_validation :set_owner, :skip_validation_for_custom_attributes, :set_owner_for_payment_documents

  after_create :set_cancellation_policy

  state_machine :state, initial: :inactive do
    after_transition inactive: :unconfirmed, do: :activate_order!
    after_transition unconfirmed: :confirmed, do: [:set_confirmed_at, :set_archived_at]
    after_transition confirmed: [:cancelled_by_guest, :cancelled_by_host], do: [:mark_as_archived!, :set_cancelled_at, :perform_cancel_actions, :cancel_deliveries]
    after_transition unconfirmed: [:cancelled_by_host], do: [:mark_as_archived!]
    after_transition unconfirmed: [:cancelled_by_guest, :expired, :rejected], do: [:mark_as_archived!, :schedule_void]
    after_transition any => [:rejected] { |o| WorkflowStepJob.perform("WorkflowStep::#{o.class.workflow_class}Workflow::Rejected".constantize, o.id, as: o.creator) }

    event :activate                 do transition inactive: :unconfirmed; end
    event :confirm                  do transition unconfirmed: :confirmed; end
    event :reject                   do transition unconfirmed: :rejected; end
    event :host_cancel              do transition [:inactive, :unconfirmed, :confirmed] => :cancelled_by_host, if: ->(order) { order.cancellable? }; end
    event :user_cancel              do transition [:inactive, :unconfirmed, :confirmed] => :cancelled_by_guest, if: ->(reservation) { reservation.archived_at.nil? }; end
    event :expire                   do transition unconfirmed: :expired; end
    event :completed                do transition confirmed: :completed; end
    event :archive                  do transition [:confirmed, :completed] => :archived; end
  end

  scope :searchable, -> { without_state(:inactive) }
  scope :cart, -> { with_state(:inactive) }
  scope :complete, -> { without_state(:inactive) }
  scope :active, -> { without_state(:inactive) }
  scope :active_or_drafts, -> { where('orders.state != ? OR orders.draft_at IS NOT NULL', 'inactive') }
  # TODO: we should switch to use completed state instead of archived_at for Reservation
  # and fully switch to state machine

  # scope :archived, -> { active.where('archived_at IS NOT NULL') }
  # scope :not_archived, -> { active.where(archived_at: nil) }
  scope :not_archived, -> { where("(orders.type != 'RecurringBooking' AND (orders.state != 'inactive' OR orders.draft_at IS NOT NULL) AND orders.archived_at IS NULL) OR (orders.type = 'RecurringBooking' AND (orders.state NOT IN ('inactive', 'cancelled_by_guest', 'cancelled_by_host', 'rejected', 'expired') OR (orders.state = 'inactive' AND orders.draft_at IS NOT NULL)))") }
  scope :archived, -> { where("(orders.type != 'RecurringBooking' AND orders.archived_at IS NOT NULL) OR (orders.type = 'RecurringBooking' AND orders.state IN ('rejected', 'expired', 'cancelled_by_host', 'cancelled_by_guest'))") }
  # we probably want new state - completed
  scope :reviewable, -> { where.not(archived_at: nil).where("orders.state = 'confirmed' OR orders.type='RecurringBooking' OR (orders.type='Offer' AND orders.state = 'archived')") }
  scope :cancelled, -> { with_state(:cancelled_by_guest, :cancelled_by_host) }
  scope :confirmed, -> { with_state(:confirmed) }
  scope :confirmed_or_archived, -> { with_state(:confirmed, :archived) }
  scope :confirmed_or_unconfirmed, -> { with_state(:confirmed, :unconfirmed) }
  scope :expired, -> { with_state(:expired) }
  scope :for_listing, ->(listing) { where(transactable_id: listing.id) }
  scope :last_x_days, ->(days_in_past) { where('DATE(orders.created_at) >= ? ', days_in_past.days.ago) }
  scope :not_rejected_or_cancelled, -> { without_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :inactive) }
  scope :past, -> { where('ends_at < ?', Time.current) }
  scope :rejected, -> { with_state(:rejected) }
  scope :unconfirmed, -> { with_state(:unconfirmed) }
  scope :upcoming, -> { not_archived }
  scope :visible, -> { without_state(:cancelled_by_guest, :cancelled_by_host, :inactive).upcoming }
  scope :with_listing, -> { where.not(transactable_id: nil) }
  scope :reservations, -> { where(type: %w(Reservation DelayedReservation)) }
  scope :offers, -> { where(type: %w(Offer)) }
  scope :for_lister_or_enquirer, ->(company, user) { where('orders.company_id = ? OR orders.user_id = ?', company.id, user.id) }

  scope :on, lambda { |date|
    joins(:periods)
      .where('reservation_periods.date' => date)
      .where(state: [:confirmed, :unconfirmed])
      .uniq
  }

  scope :cancelled_or_expired_or_rejected, lambda {
    with_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired)
  }

  scope :by_period, lambda { |start_date, end_date = Time.zone.today.end_of_day|
    where(created_at: start_date..end_date)
  }

  scope :by_buyer_name, ->(name) { joins('inner join users on users.id = orders.owner_id').where('users.name like ?', "%#{name}%") }

  scope :by_seller_name, ->(name) { joins('inner join users on users.id = orders.creator_id').where('users.name like ?', "%#{name}%") }

  scope :by_order_state, ->(state) { where('state = ?', state) }

  scope :non_free_orders, -> { where('is_free_booking = ?', false) }

  scope :free_orders, -> { where('is_free_booking = ?', true) }

  scope :sorted_by_date, ->(value) {
                           direction = if %w(asc desc).include?(value)
                                         value
                                       else
                                         'desc'
                                                 end
                           order("created_at #{direction}")
                         }

  scope :sorted_by_total_paid, ->(value) {
                                 direction = if %w(asc desc).include?(value)
                                               value
                                             else
                                               'desc'
                                                 end
                                 joins("left join (
                                                   select sum(li.unit_price_cents * li.quantity) as paid, rbp.order_id as order_id
                                                   from recurring_booking_periods rbp
                                                   inner join line_items li on li.line_itemable_id = rbp.id AND li.line_itemable_type = 'RecurringBookingPeriod'
                                                   where rbp.paid_at is not null group by rbp.order_id
                                                  ) order_info ON order_info.order_id = orders.id
                                        left join (
                                                   select sum(line_items.unit_price_cents * line_items.quantity) as paid, line_itemable_id, line_itemable_type
                                                   from line_items group by line_itemable_id, line_itemable_type
                                                  ) line_items ON line_items.line_itemable_id = orders.id AND line_items.line_itemable_type = orders.type
                                        left join (
                                                   select sum(total_amount_cents) as sum_amount, payable_id, payable_type
                                                   from payments group by payable_id, payable_type
                                                  ) payments_info ON payments_info.payable_id = orders.id and payments_info.payable_type = orders.type")
                                   .order("coalesce(nullif(payments_info.sum_amount, 0), nullif(order_info.paid, 0), line_items.paid, 0) #{direction}, created_at DESC")
                               }
  scope :recurring, -> { includes(:periods).where.not(reservation_periods: { recurring_frequency: nil, recurring_frequency_unit: nil }) }
  scope :needs_new_order_item, lambda { |time|
    recurring
      .with_state(:confirmed)
      .includes(:order_items)
      .where('generate_order_item_at <= ?', time)
      .where.not(recurring_booking_periods: { id: nil })
  }

  delegate :service_fee_guest_percent, :service_fee_host_percent, :action,
           to: :transactable_pricing
  delegate :minimum_lister_service_fee_cents, :favourable_pricing_rate,
           to: :action
  delegate :photos, :confirm_reservations?, :display_additional_charges?,
           to: :transactable, allow_nil: true

  # You can customize order tabs (states) displauyed in dashboard
  # via orders_received_tabs and my_orders_tabs Instance attributes

  def self.workflow_class
    raise NotImplementedError
  end

  def self.dashboard_tabs(company_dashboard = false)
    if company_dashboard
      PlatformContext.current.instance.orders_received_tabs
    else
      PlatformContext.current.instance.my_orders_tabs
    end.presence || DEFAULT_DASHBOARD_TABS
  end

  def perform_cancel_actions(_transition, run_at = Time.zone.now)
    PaymentRefundJob.perform_later(run_at, payment.id, refund_amount_cents) if payment.try(:paid?) && refund_amount_cents > 0
    ChargeCancellationPenaltyJob.perform_later(run_at, id, penalty_amount_cents) if payment && !payment.paid? && penalty_amount_cents > 0
    true
  end

  def penalty_amount_with_service_fee_cents
    refund_amount_cents + (refund_amount_cents * service_fee_guest_percent.to_f / BigDecimal(100))
  end

  monetize :refund_amount_cents, with_model_currency: :currency
  def refund_amount_cents
    cancellation_policies.refunds.map(&:amount_cents).sum
  end

  monetize :penalty_amount_cents, with_model_currency: :currency
  def penalty_amount_cents
    cancellation_policies.penalties.map(&:amount_cents).sum
  end

  # This is workaround to use STI class with routing Rails standards
  def routing_object
    Order.new(id: id)
  end

  def process!
    return false unless valid? && can_process?
    if skip_payment_authorization
      return false unless payment_processor.blank? || payment_processor.payment_source.try(:process!)
    else
      return false unless payment_processor.blank? || payment_processor.process!
    end
    activate! if inactive? && can_activate?
    save
  end

  def payment_processor
    payment || payment_subscription
  end

  def can_activate?
    payment_processor.try(:can_activate?)
  end

  def complete!
    # TODO: soon we will introduce "completed" state instead of archived_at timestamp
    touch(:archived_at)
  end

  # @return [Boolean] whether the order has been moved to the archived state
  def archived?
    archived_at.present?
  end

  def completed?
    # TODO: soon we will introduce "completed" state instead of archived_at timestamp
    archived?
  end

  def is_free?
    total_amount.to_f <= 0
  end

  # @return [Boolean] whether the order has been paid for
  def paid?
    payment.try(:paid?)
  end

  def cancelled?
    cancelled_by_host? || cancelled_by_guest?
  end

  def subscription?
    type == 'RecurringBooking'
  end

  def has_order_items?
    order_items.any?
  end

  # @return [Boolean] whether the object is bookable (i.e. its type is different from 'Purchase')
  def bookable?
    type != 'Purchase'
  end

  def lister_confirmed!
    touch(:lister_confirmed_at)
  end

  def enquirer_confirmed!
    touch(:enquirer_confirmed_at)
  end

  # @return [String] identifer of the order containing the class name (type of order)
  #   and the numeric identifer of the order
  def number
    id
  end

  def should_validate_field?(key, value)
    return false if next_form_component_id.blank?
    return false if skip_checkout_validation
    return false unless inactive?

    reservation_type.form_components.find(next_form_component_id).form_fields.select do |f|
      f[key] == value
    end.any?
  end

  def checkout_completed?
    return true unless reservation_type.step_checkout?
    return false if completed_form_component_ids.blank?
    return false if reservation_type.form_components.where.not(id: completed_form_component_ids).any?
    true
  end

  def step_control
    @step_control ||= (cached_completed_form_component_ids + [next_form_component_id]).join(',')
  end

  def step_control=(step_control_attribute)
    if step_control == step_control_attribute
      self.completed_form_component_ids = (cached_completed_form_component_ids + [next_form_component_id]).join(',')
    end
  end

  def next_form_component_id
    @next_form_component_id ||= next_form_component.try(:id)
  end

  def next_form_component
    return nil if reservation_type.blank?
    @next_form_component ||= reservation_type.form_components.where.not(id: cached_completed_form_component_ids).order(:rank).find { |fc| fc.form_fields_except(skip_steps).any? }
  end

  def all_form_components
    reservation_type.form_components.order(:rank).select { |fc| fc.form_fields_except(skip_steps).any? }
  end

  def next_form_component_name_to_id
    next_form_component.try(:name_to_id)
  end

  def previous_step!
    update_column(:completed_form_component_ids, cached_completed_form_component_ids[0..-2].join(','))
  end

  def restore_cached_step!
    update_column(:completed_form_component_ids, cached_completed_form_component_ids.join(','))
  end

  def completed_form_component_ids
    self[:completed_form_component_ids].to_s.split(',')
  end

  def cached_completed_form_component_ids
    @completed_ids ||= self[:completed_form_component_ids].to_s.split(',')
  end

  def remove_empty_documents
    return if PlatformContext.current.instance.documents_upload.try(:is_mandatory?)

    payment_documents.each do |document|
      next if document.valid? || document.is_file_required?

      payment_documents.delete(document)
    end
  end

  def merchant_subject
    company.merchant_accounts.where(type: 'MerchantAccount::PaypalExpressChainMerchantAccount').verified.first.try(:subject)
  end

  def host
    @host ||= creator
  end

  def administrator
    super.presence || creator
  end

  def cancellable?
    return false if cancelled? || archived? || rejected?
    return true if cancellation_policies.allowed.blank?

    cancellation_policies.allowed.all?(&:conditions_met?)
  end

  # @return [Boolean] whether the penalty charge applies to this order
  def penalty_charge_apply?
    return false if cancellation_policies.penalties.blank?
    cancellation_policies.penalties.any?(&:conditions_met?)
  end

  # ----- SETTERS ---------
  def set_cancelled_at
    touch(:cancelled_at)
  end

  def activate_order!
    schedule_expiry
    auto_confirm_reservation
    pre_booking_job
  end

  def pre_booking_job
    return true if starts_at.nil?
    pre_booking_sending_date = (starts_at - 1.day).in_time_zone + 17.hours # send day before at 5pm
    if pre_booking_sending_date < Time.current.beginning_of_day
      ReservationPreBookingJob.perform_later(pre_booking_sending_date, id)
    end
  end

  def restart_checkout!
    update_columns(completed_form_component_ids: '')
  end

  def mark_as_archived!
    if archived_at.nil?
      touch(:archived_at)

      trigger_rating_workflow!

      transactables.each do |transactable|
        ElasticIndexerJob.perform(:update, transactable.class.to_s, transactable.id)
      end
    end
    true
  end

  def schedule_void
    PaymentVoidJob.perform(payment.id) if payment.try(:authorized?)
    true
  end

  def trigger_rating_workflow!
    if archived? && confirmed?
      if request_guest_rating_email_sent_at.blank? && RatingSystem.active_with_subject(RatingConstants::GUEST).where(transactable_type_id: transactable_type_id).exists?
        WorkflowStepJob.perform("WorkflowStep::#{self.class.workflow_class}Workflow::EnquirerRatingRequested".constantize, id)
        update_column(:request_guest_rating_email_sent_at, Time.zone.now)
      end

      if request_host_and_product_rating_email_sent_at.blank? && RatingSystem.active_with_subject([RatingConstants::HOST, RatingConstants::TRANSACTABLE]).where(transactable_type_id: transactable_type_id).exists?
        WorkflowStepJob.perform("WorkflowStep::#{self.class.workflow_class}Workflow::ListerRatingRequested".constantize, id)
        update_column(:request_host_and_product_rating_email_sent_at, Time.zone.now)
      end
    end
  end

  def set_confirmed_at
    touch(:confirmed_at)
  end

  def set_archived_at
    OrderMarkAsArchivedJob.perform_later(ends_at, id) if ends_at
  end

  # TODO: remove owner and stick to the user
  def set_owner
    self.owner_id ||= user_id
  end

  def validate_on_adding_to_cart
    super == 'true'
  end
  alias validate_on_adding_to_cart? validate_on_adding_to_cart

  def skip_payment_authorization
    super == 'true'
  end
  alias skip_payment_authorization? skip_payment_authorization

  def validate_acceptance_of_waiver_agreements
    assigned_waiver_agreement_templates.each do |wat|
      if waiver_agreements.select { |w| w.waiver_agreement_template_id == wat.id && !w.marked_for_destruction? }.blank?
        errors.add(wat.name, I18n.t('errors.messages.accepted'))
      end
    end
  end

  def assigned_waiver_agreement_templates
    templates = []
    transactables.each do |transactable|
      if transactable.try(:assigned_waiver_agreement_templates).try(:any?)
        templates << transactable.assigned_waiver_agreement_templates.includes(:waiver_agreement_template).map(&:waiver_agreement_template)
      elsif transactable.try(:location).try(:assigned_waiver_agreement_templates).try(:any?)
        templates << transactable.location.assigned_waiver_agreement_templates.includes(:waiver_agreement_template).map(&:waiver_agreement_template)
      else
        templates << PlatformContext.current.instance.waiver_agreement_templates
      end
    end
    templates.flatten.uniq
  end

  def additional_charge_types
    ids = transactables.map(&:all_additional_charge_types_ids).flatten
    AdditionalChargeType.where(id: ids).order(:status, :name)
  end

  def recalculate_service_fees!
    if service_fee_line_items.any?
      service_fee_line_items.first.update_attribute(:unit_price_cents,
                                                    transactable_line_items.map { |t| t.total_price_cents * t.service_fee_guest_percent.to_f / BigDecimal(100) }.sum)
    end

    if host_fee_line_items.any?
      host_fee_line_items.first.update_attribute(:unit_price_cents,
                                                 transactable_line_items.map { |t| t.total_price_cents * t.service_fee_host_percent.to_f / BigDecimal(100) }.sum)
    end
  end

  def skip_steps
    steps = []
    steps << 'payment_documents' unless transactables.any? { |t| t.upload_obligation.try(:not_required?) == false }
    steps << 'shipping' unless with_delivery?
    steps.join('|')
  end

  # @!method confirm_reservations?
  #   @return [Boolean] whether reservations need to be confirmed first
  delegate :confirm_reservations?, to: :transactable
  delegate :redirect_to_gateway, to: :payment, allow_nil: true

  def transactable_pricing
    super || transactable_line_items.first.transactable_pricing
  end

  def reject(reason = nil)
    self.rejection_reason = reason if reason
    fire_state_event :reject, reason
  end

  def message_context_object
    self
  end

  def custom_attributes_custom_validators
    @custom_attributes_custom_validators ||= { properties: reservation_type.custom_attributes_custom_validators }
  end

  # @return [Boolean] whether checkout can be completed for this Order object
  def can_complete_checkout?
    raise NotImplementedError
  end

  # @return [Boolean] whether checkout can be approved or declined for this Order object
  def can_approve_or_decline_checkout?
    raise NotImplementedError
  end

  # @return [Boolean] whether the user needs to update their credit card
  def has_to_update_credit_card?
    raise NotImplementedError
  end

  # @return [Boolean] whether the order is in a state where it can be
  #   cancelled by the enquirer
  def enquirer_cancellable
    raise NotImplementedError
  end

  # @return [Boolean] whether the order is in a state where it can be edited
  #   by the enquirer
  def enquirer_editable
    raise NotImplementedError
  end

  def try_to_activate!
    return true unless inactive? && valid?

    activate! if payment && payment.can_activate?
  end

  def to_liquid
    @drop ||= OrderDrop.new(self)
  end

  def conflicting_orders
    Order::ConflictingOrders.new(order: self).by_quantity
  end

  def price_calculator
    @price_calculator ||= transactable_pricing.price_calculator(self)
  end
  alias amount_calculator price_calculator

  def can_process?
    true
  end

  private

  def set_cancellation_policy
    if transactable_pricing && transactable_pricing.action && transactable_pricing.action.cancellation_policies.any?
      transactable_pricing.action.cancellation_policies.each do |cp|
        cancellation_policies << cp.dup
      end
    end
    true
  end

  def skip_validation_for_custom_attributes
    self.skip_custom_attribute_validation = !checkout_update
    true
  end

  def set_owner_for_payment_documents
    if payment_documents.present?
      payment_documents.each do |payment_document|
        payment_document.user = owner if payment_document.new_record?
      end
    end

    true
  end

  def send_rejected_workflow_alerts!
  end
end
