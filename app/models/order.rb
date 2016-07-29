class Order < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end

  ORDER_TYPES = ['Reservation', 'RecurringBooking', 'Purchase', 'DelayedReservation']

  include Encryptable
  include Modelable
  include Payable

  attr_accessor :skip_checkout_validation, :delivery_ids, :skip_try_to_activate
  store_accessor :settings, :validate_on_adding_to_cart, :skip_payment_authorization

  has_custom_attributes target_type: 'ReservationType', target_id: :reservation_type_id

  belongs_to :user, -> { with_deleted }
  # TODO creator is not intuitive name we should switch to the "lister"
  belongs_to :creator, -> { with_deleted }, class_name: "User"
  belongs_to :owner, -> { with_deleted }, :class_name => "User", counter_cache: true
  belongs_to :administrator, -> { with_deleted }, class_name: "User"
  belongs_to :company, -> { with_deleted }
  belongs_to :currency_object, foreign_key: :currency, primary_key: :iso_code, class_name: "Currency"
  belongs_to :shipping_address, foreign_key: :shipping_address_id, class_name: 'OrderAddress'
  belongs_to :billing_address, foreign_key: :billing_address_id, class_name: 'OrderAddress'
  belongs_to :reservation_type
  belongs_to :transactable, -> { with_deleted }
  belongs_to :transactable_pricing, class_name: 'Transactable::Pricing'

  has_one :dimensions_template, as: :entity

  has_many :payment_documents, as: :attachable, class_name: 'Attachable::PaymentDocument', dependent: :destroy
  has_many :reviews, as: :reviewable
  has_many :shipments, dependent: :destroy, inverse_of: :order
  has_many :user_messages, as: :thread_context
  has_many :periods, :class_name => "::ReservationPeriod", :dependent => :destroy, foreign_key: 'reservation_id', inverse_of: :reservation
  has_many :waiver_agreements, as: :target
  has_many :transactables, through: :transactable_line_items, source: :line_item_source, source_type: 'Transactable'

  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :payment_documents
  accepts_nested_attributes_for :shipping_address
  accepts_nested_attributes_for :shipments

  validates :user, presence: true
  validates :currency, :presence => true
  validate :validate_acceptance_of_waiver_agreements, on: :update, if: -> { should_validate_field?('reservation', 'waiver_agreements') }

  before_validation :copy_billing_address, :remove_empty_documents
  before_validation :set_owner, :build_return_shipment
  after_save :try_to_activate!, unless: -> { skip_try_to_activate }

  state_machine :state, initial: :inactive do
    after_transition inactive: :unconfirmed, do: :activate_order!
    after_transition unconfirmed: :confirmed, do: [:set_confirmed_at, :set_archived_at]
    after_transition confirmed: [:cancelled_by_guest, :cancelled_by_host], do: [:mark_as_archived!, :set_cancelled_at, :schedule_refund]
    after_transition unconfirmed: [:cancelled_by_host], do: [:mark_as_archived!]
    after_transition unconfirmed: [:cancelled_by_guest, :expired, :rejected], do: [:mark_as_archived!, :schedule_void]

    event :activate                 do transition inactive: :unconfirmed; end
    event :confirm                  do transition unconfirmed: :confirmed; end
    event :reject                   do transition unconfirmed: :rejected; end
    event :host_cancel              do transition [:unconfirmed, :confirmed] => :cancelled_by_host, if: lambda {|order| order.cancelable? }; end
    event :user_cancel              do transition [:unconfirmed, :confirmed] => :cancelled_by_guest, if: lambda {|reservation| reservation.archived_at.nil? }; end
    event :expire                   do transition unconfirmed: :expired; end
    event :completed                do transition confirmed: :completed; end
  end

  scope :searchable, -> { without_state(:inactive)  }
  scope :cart, -> { with_state(:inactive) }
  scope :complete, -> { without_state(:inactive) }
  scope :active, -> { without_state(:inactive) }
  scope :archived, -> { active.where('archived_at IS NOT NULL') }
  scope :not_archived, -> { active.where(archived_at: nil) }
  scope :reviewable, -> { where.not(archived_at: nil).confirmed }
  scope :cancelled, -> { with_state(:cancelled_by_guest, :cancelled_by_host) }
  scope :confirmed, -> { with_state(:confirmed)}
  scope :confirmed_or_unconfirmed, -> { with_state(:confirmed, :unconfirmed) }
  scope :expired, -> { with_state(:expired) }
  scope :for_listing, -> (listing) { where(:transactable_id => listing.id) }
  scope :last_x_days, -> (days_in_past) { where('DATE(orders.created_at) >= ? ', days_in_past.days.ago) }
  scope :not_rejected_or_cancelled, -> { without_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :inactive) }
  scope :past, -> { where("ends_at < ?", Time.current)}
  scope :rejected, -> { with_state(:rejected) }
  scope :unconfirmed, -> { with_state(:unconfirmed) }
  scope :upcoming, -> { not_archived }
  scope :visible, -> { without_state(:cancelled_by_guest, :cancelled_by_host, :inactive).upcoming }
  scope :with_listing, -> { where.not(transactable_id: nil) }
  scope :reservations, -> { where(type: %w(Reservation DelayedReservation)) }

  scope :on, -> (date) {
    joins(:periods).
    where("reservation_periods.date" => date).
    where(:state => [:confirmed, :unconfirmed]).
    uniq
  }

  scope :cancelled_or_expired_or_rejected, -> {
    with_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired)
  }

  scope :by_period, -> (start_date, end_date = Time.zone.today.end_of_day) {
    where(created_at: start_date..end_date)
  }

  delegate :photos, to: :transactable, allow_nil: true

  def schedule_refund(transition, run_at = Time.zone.now)
    if payment.paid? && !skip_payment_authorization?
      PaymentRefundJob.perform_later(run_at, payment.id)
    end
    true
  end

  def complete!
    # TODO soon we will introduce "completed" state instead of archived_at timestamp
    touch(:archived_at)
  end

  def completed?
    # TODO soon we will introduce "completed" state instead of archived_at timestamp
    archived?
  end

  def create_shipments!
    CreateShippoShipmentsJob.perform(self.id) if shipments.any?(&:use_shippo?)
  end

  def is_free?
    total_amount.to_f <= 0
  end

  def paid?
    payment.try(:paid?)
  end

  def cancelled?
    cancelled_by_host? || cancelled_by_guest?
  end

  def subscription?
    type == "RecurringBooking"
  end

  def bookable?
    type != "Purchase"
  end

  def number
    sprintf "#{self.class.name[0]}%08d", id
  end

  def should_validate_field?(key, value)
    return false if next_form_component_id.blank?
    return false if skip_checkout_validation
    return false unless inactive?

    reservation_type.form_components.find(next_form_component_id).form_fields.select do |f|
      f[key] == value
    end.any?
  end

  before_update :set_completed_form_component_ids
  def set_completed_form_component_ids
    self.completed_form_component_ids = (completed_form_component_ids + [next_form_component_id]).join(',')
  end

  def next_form_component_id
    next_form_component.try(:id)
  end

  def next_form_component
    return nil if reservation_type.blank?
    reservation_type.form_components.where.not(id: completed_form_component_ids).order(:rank).select{ |fc| fc.form_fields_except(skip_steps).any? }.first
  end

  def all_form_components
    reservation_type.form_components.order(:rank).select{ |fc| fc.form_fields_except(skip_steps).any? }
  end

  def next_form_component_name_to_id
    next_form_component.try(:name_to_id)
  end

  def previous_step!
    self.update_column(:completed_form_component_ids, completed_form_component_ids[0..-2].join(','))
  end


  def completed_form_component_ids
    read_attribute(:completed_form_component_ids).to_s.split(',')
  end

  def with_delivery?
    transactables.any?(&:shipping_profile)
  end

  # TODO implement with shipping
  def shipped?
    true
  end

  def remove_empty_documents
    self.payment_documents.each do |document|
      unless document.valid?
        unless PlatformContext.current.instance.documents_upload.is_mandatory? || document.document_requirement.is_file_required?
          self.payment_documents.delete document
        end
      end
    end
  end

  def merchant_subject
    company.paypal_express_chain_merchant_account.try(:subject)
  end

  def host
    @host ||= creator
  end

  def administrator
    super.presence || creator
  end

  # TODO chante to order.id and adjust routes
  def express_return_url
    PlatformContext.current.decorate.build_url_for_path("/orders/#{self.id}/express_checkout/return")
  end

  def express_cancel_return_url
    PlatformContext.current.decorate.build_url_for_path("/orders/#{self.id}/express_checkout/cancel")
  end


  # ----- SETTERS ---------
  def set_cancelled_at
    touch(:cancelled_at)
  end

  def activate_order!
    schedule_expiry
    auto_confirm_reservation
    pre_booking_job
    first_booking_job
  end

  def pre_booking_job
    return true if self.starts_at.nil?
    pre_booking_sending_date = (self.starts_at - 1.day).in_time_zone + 17.hours # send day before at 5pm
    if pre_booking_sending_date < Time.current.beginning_of_day
      ReservationPreBookingJob.perform_later(pre_booking_sending_date, self.id)
    end
  end

  def first_booking_job
    if self.user.orders.reservations.active.count == 1
      ReengagementOneBookingJob.perform_later(self.last_date.in_time_zone + 7.days, self.id)
    end
  end

  def shipping_address
    if use_billing && billing_address
      billing_address.dup
    else
      super
    end
  end

  def copy_billing_address
    if self.use_billing
      self.shipping_address = nil
    end
  end

  def restart_checkout!
    self.update_columns(completed_form_component_ids: '')
  end

  def mark_as_archived!
    if archived_at.nil?
      touch(:archived_at)

      trigger_rating_workflow!

      unless Rails.env.test?
        begin
          transactable.__elasticsearch__.update_document_attributes(completed_reservations: transactable.orders.reservations.reviewable.count)
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
        end
      end
    end
    true
  end

  def schedule_void
    if payment.try(:authorized?)
      PaymentVoidJob.perform(payment.id)
    end
    true
  end


  def trigger_rating_workflow!
    if archived? && confirmed?
      if request_guest_rating_email_sent_at.blank? && RatingSystem.active_with_subject(RatingConstants::GUEST).where(transactable_type_id: transactable_type_id).exists?
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::GuestRatingRequested, id)
        update_column(:request_guest_rating_email_sent_at, Time.zone.now)
      end

      if request_host_and_product_rating_email_sent_at.blank? && RatingSystem.active_with_subject([RatingConstants::HOST, RatingConstants::TRANSACTABLE]).where(transactable_type_id: transactable_type_id).exists?
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::HostRatingRequested, id)
        update_column(:request_host_and_product_rating_email_sent_at, Time.zone.now)
      end
    end
  end

  def set_confirmed_at
    touch(:confirmed_at)
  end

  def set_archived_at
    OrderMarkAsArchivedJob.perform_later(self.ends_at, self.id) if self.ends_at
  end

  # TODO remove owner and stick to the user
  def set_owner
    self.owner_id ||= self.user_id
  end

  def validate_on_adding_to_cart
    super == "true"
  end
  alias :validate_on_adding_to_cart? :validate_on_adding_to_cart

  def skip_payment_authorization
    super == "true"
  end
  alias :skip_payment_authorization? :skip_payment_authorization

  def waiver_agreement_templates
    @waiver_agreement_templates ? @waiver_agreement_templates.select {|k, v| v == '1'} : []
  end

  def waiver_agreement_templates=(selected_waiver_agreement_templates)
    waiver_agreements.destroy_all
    @waiver_agreement_templates = selected_waiver_agreement_templates
    assigned_waiver_agreement_templates.select { |w| waiver_agreement_templates.include?(w.id.to_s) }.each do |t|
      if self.persisted?
        waiver_agreements.create(waiver_agreement_template: t, vendor_name: self.host.try(:name), guest_name: self.owner.name, target: self)
      else
        waiver_agreements.build(waiver_agreement_template: t, vendor_name: self.host.try(:name), guest_name: self.owner.name, target: self)
      end
    end
  end

  def validate_acceptance_of_waiver_agreements
    self.assigned_waiver_agreement_templates.each do |wat|
      wat_id = wat.id
      unless waiver_agreement_templates.include?("#{wat_id}")
        self.errors.add(wat.name, I18n.t('errors.messages.accepted'))
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
    templates.flatten
  end

  def additional_charge_types
    ids = transactables.map(&:all_additional_charge_types_ids).flatten
    AdditionalChargeType.where(id: ids).order(:status, :name)
  end

  def recalculate_service_fees!
    if self.service_fee_line_items.any?
      self.service_fee_line_items.first.update_attribute(:unit_price_cents,
        self.transactable_line_items.map {|t| t.total_price_cents * t.service_fee_guest_percent.to_f / BigDecimal(100) }.sum
      )
    end

    if self.host_fee_line_items.any?
      self.host_fee_line_items.first.update_attribute(:unit_price_cents,
        self.transactable_line_items.map {|t| t.total_price_cents * t.service_fee_host_percent.to_f / BigDecimal(100) }.sum
      )
    end
  end

  def delivery_ids=(ids)
    errors.add(:delivery_ids, :blank) if shipments.any? && ids.blank?
    if ids.present? && shipments.any?
      ids.split(',').each do |delivery|
        shipments.each do |shipment|
          shipment.shippo_rate_id = delivery.split(':')[1] if shipment.direction == delivery.split(':')[0]
        end
      end
    end
  end

  def build_return_shipment
    if shipments.one? && shipments.first.shipping_rule.shipping_profile.shippo_return? && shipping_address.valid?
      outbound_shipping = shipments.first
      inbound_shipping = outbound_shipping.dup
      inbound_shipping.direction = 'inbound'
      shipping_address.create_shippo_address
      self.shipments << inbound_shipping
    end
  end

  def get_shipping_rates
    return [] if shipments.none?(&:use_shippo?)
    return @options unless @options.nil?
    rates = []
    # Get rates for both ways shipping (rental shipping)
    shipments.each do |shipment|
      shipment.get_rates(self).map{|rate| rate[:direction] = shipment.direction; rates << rate }
    end
    rates = rates.flatten.group_by{ |rate| rate[:servicelevel_name] }
    @options = rates.to_a.map do |type, rate|
      # Skip if service is available only in one direction
      # next if rate.one?
      price_sum = Money.new(rate.sum{|r| r[:amount_cents].to_f }, rate[0][:currency])
      # Format options for simple_form radio
      [
        [ price_sum.format, "#{rate[0][:provider]} #{rate[0][:servicelevel_name]}", rate[0][:duration_terms]].join(' - '),
        rate.map{|r| "#{r[:direction]}:#{r[:object_id]}" }.join(','),
        { data: { price_formatted: price_sum.format, price: price_sum.to_f } }
      ]
    end.compact
  end

  def skip_steps
    steps = []
    steps << 'payment_documents' unless transactables.any?{|t| t.upload_obligation.try(:not_required?) == false }
    steps << 'shipping' unless with_delivery?
    steps.join('|')
  end

  def confirm_reservations?
    transactable.confirm_reservations?
  end

  def transactable_pricing
    super || transactable_line_items.first.transactable_pricing
  end

  private

  def try_to_activate!
    if inactive? && (skip_payment_authorization? || payment && payment.authorized?)
      activate!
    end
  end

end
