require_dependency 'line_item/transactable'

# frozen_string_literal: true
class Transactable < ActiveRecord::Base
  include CustomImagesOwnerable
  include CustomAttachmentsOwnerable
  include CustomizationsOwnerable
  include CategoriesOwnerable
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  include Impressionable
  include Searchable
  # FIXME: disabled Sitemap updates. Needs to be optimized.
  # include SitemapService::Callbacks
  # == Helpers
  include Listing::Search
  include Categorizable
  include Approvable
  include Taggable
  include ShippoLegacy::Transactable
  include Shippings::Transactable

  DEFAULT_ATTRIBUTES = %w(name description capacity).freeze

  SORT_OPTIONS_MAP = { all: 'All', featured: 'Featured', most_recent: 'Most Recent', most_popular: 'Most Popular', collaborators: 'Collaborators' }.freeze
  SORT_OPTIONS = SORT_OPTIONS_MAP.values.freeze

  DATE_VALUES = %w(today yesterday week_ago month_ago 3_months_ago 6_months_ago).freeze

  # This must go before has_custom_attributes because of how the errors for the custom
  # attributes are added to the instance
  include CommunityValidators
  has_custom_attributes target_type: 'TransactableType', target_id: :transactable_type_id
  has_metadata accessors: [:photos_metadata]
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id, :listings_public], :location)

  include CreationFilter

  has_many :additional_charge_types, foreign_type: :charge_type_target_type, foreign_key: :charge_type_target_id
  has_many :availability_templates, as: :parent
  has_many :approval_requests, as: :owner, dependent: :destroy
  has_many :assigned_waiver_agreement_templates, as: :target
  has_many :billing_authorizations, as: :reference
  has_many :document_requirements, as: :item, dependent: :destroy, inverse_of: :item
  has_many :impressions, as: :impressionable, dependent: :destroy
  has_many :photos, as: :owner, dependent: :destroy do
    def thumb
      (first || build).thumb
    end

    def except_cover
      offset(1)
    end
  end
  has_many :attachments, -> { order(:id) }, class_name: 'SellerAttachment', as: :assetable
  has_many :recurring_bookings, inverse_of: :transactable
  has_many :orders
  has_many :reservations
  has_many :transactable_line_items, class_name: 'LineItem::Transactable', as: :line_item_source
  has_many :line_item_orders, class_name: 'Order', through: :transactable_line_items, source: :order
  has_many :transactable_tickets, as: :target, class_name: 'Support::Ticket'
  has_many :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many :waiver_agreement_templates, through: :assigned_waiver_agreement_templates
  has_many :wish_list_items, as: :wishlistable
  has_many :billing_authorizations, as: :reference
  has_many :inappropriate_reports, as: :reportable, dependent: :destroy
  has_many :action_types, inverse_of: :transactable
  has_many :data_source_contents, through: :transactable_topics
  belongs_to :transactable_type, -> { with_deleted }
  belongs_to :company, -> { with_deleted }, inverse_of: :listings
  belongs_to :location, -> { with_deleted }, inverse_of: :listings, touch: true
  belongs_to :instance, inverse_of: :listings
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: :listings
  belongs_to :user, -> { with_deleted }, foreign_key: :creator_id, inverse_of: :listings
  counter_culture :creator,
                  column_name: ->(t) { t.draft.nil? ? 'transactables_count' : nil },
                  column_names: { ['transactables.draft IS NULL AND transactables.deleted_at IS NULL'] => 'transactables_count' }

  belongs_to :administrator, -> { with_deleted }, class_name: 'User', inverse_of: :administered_listings

  has_one :location_address, through: :location
  has_one :upload_obligation, as: :item, dependent: :destroy
  has_one :event_booking, inverse_of: :transactable
  has_one :subscription_booking, inverse_of: :transactable
  has_one :time_based_booking, inverse_of: :transactable
  has_one :no_action_booking, inverse_of: :transactable
  has_one :purchase_action, inverse_of: :transactable
  has_one :offer_action, inverse_of: :transactable
  belongs_to :action_type, inverse_of: :transactable

  has_many :activity_feed_events, as: :followed, dependent: :destroy
  has_many :activity_feed_subscriptions, as: :followed, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :feed_followers, through: :activity_feed_subscriptions, source: :follower
  has_many :transactable_topics, dependent: :destroy
  has_many :topics, through: :transactable_topics
  has_many :approved_transactable_collaborators, -> { approved }, class_name: 'TransactableCollaborator', dependent: :destroy
  has_many :collaborating_users, through: :approved_transactable_collaborators, source: :user
  has_many :transactable_collaborators, dependent: :destroy
  has_many :group_transactables, dependent: :destroy
  has_many :groups, through: :group_transactables

  has_many :activity_feed_events, as: :followed, dependent: :destroy
  has_many :activity_feed_subscriptions, as: :followed, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :feed_followers, through: :activity_feed_subscriptions, source: :follower
  has_many :links, dependent: :destroy, as: :linkable
  has_many :transactable_topics, dependent: :destroy
  has_many :topics, through: :transactable_topics
  has_many :group_transactables, dependent: :destroy
  has_many :groups, through: :group_transactables

  accepts_nested_attributes_for :additional_charge_types, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :attachments, allow_destroy: true
  accepts_nested_attributes_for :document_requirements, allow_destroy: true, reject_if: :document_requirement_hidden?
  accepts_nested_attributes_for :photos, allow_destroy: true
  accepts_nested_attributes_for :upload_obligation
  accepts_nested_attributes_for :waiver_agreement_templates, allow_destroy: true
  accepts_nested_attributes_for :customizations, allow_destroy: true
  accepts_nested_attributes_for :action_types, allow_destroy: true
  accepts_nested_attributes_for :links, allow_destroy: true
  accepts_nested_attributes_for :time_based_booking
  accepts_nested_attributes_for :event_booking
  accepts_nested_attributes_for :subscription_booking
  accepts_nested_attributes_for :no_action_booking
  accepts_nested_attributes_for :purchase_action
  accepts_nested_attributes_for :offer_action

  # == Callbacks

  before_create :set_seek_collaborators, if: -> { auto_seek_collaborators? }
  before_destroy :decline_reservations
  before_save :set_currency
  before_save :set_is_trusted, :set_available_actions
  before_validation :set_activated_at, :set_enabled, :set_confirm_reservations, :set_possible_payout, :set_action_type
  after_create :set_external_id
  after_save do
    if time_based_booking? && availability.try(:days_open).present?
      update_column(:opened_on_days, availability.days_open.sort)
    else
      update_column(:opened_on_days, []) if opened_on_days.any?
    end

    true
  end
  after_destroy :close_request_for_quotes
  after_destroy :fix_counter_caches
  after_destroy :fix_counter_caches_after_commit

  before_restore :restore_photos
  before_restore :restore_links
  before_restore :restore_transactable_collaborators

  after_commit :user_created_transactable_event, on: :create, unless: ->(record) { record.draft? || record.skip_activity_feed_event }
  def user_created_transactable_event
    event = :user_created_transactable
    user = creator.try(:object).presence || creator
    affected_objects = [user] + topics
    ActivityFeedService.create_event(event, self, affected_objects, self)
  end
  after_update :user_created_transactable_event_on_publish, unless: ->(record) { record.skip_activity_feed_event }
  def user_created_transactable_event_on_publish
    user_created_transactable_event if draft_changed?
  end

  # == Scopes
  scope :with_orders, -> { joins(:transactable_line_items).distinct('transactables.id') }
  scope :purchasable, -> { joins(:action_type).where("transactable_action_types.enabled = true AND transactable_action_types.type = 'Transactable::PurchaseAction'") }
  scope :featured, -> { where(featured: true) }
  scope :draft, -> { where('transactables.draft IS NOT NULL') }
  scope :active, -> { where('transactables.draft IS NULL') }
  scope :latest, -> { order('transactables.created_at DESC') }
  scope :visible, -> { where(enabled: true) }
  scope :searchable, -> { require_payout? ? active.visible.with_possible_payout : active.visible }
  scope :with_possible_payout, -> { where(possible_payout: true) }
  scope :without_possible_payout, -> { where(possible_payout: false) }
  scope :for_transactable_type_id, ->(transactable_type_id) { where(transactable_type_id: transactable_type_id) }
  scope :for_groupable_transactable_types, -> { joins(:transactable_type).where('transactable_types.groupable_with_others = ?', true) }
  scope :filtered_by_custom_attribute, ->(property, values) { where("string_to_array((transactables.properties->?), ',') && ARRAY[?]", property, values) unless values.blank? }
  scope :last_x_days, ->(days_in_past) { where('DATE(transactables.created_at) >= ? ', days_in_past.days.ago) }

  scope :not_booked_relative, lambda { |start_date, end_date|
    joins(ActiveRecord::Base.send(:sanitize_sql_array, ['LEFT OUTER JOIN (
       SELECT MIN(qty) as min_qty, transactable_id, count(*) as number_of_days_booked
       FROM (SELECT SUM(orders.quantity) as qty, orders.transactable_id, reservation_periods.date
         FROM "orders"
         INNER JOIN "reservation_periods" ON "reservation_periods"."reservation_id" = "orders"."id"
         WHERE
          "orders"."instance_id" = ? AND
          "orders"."deleted_at" IS NULL AND
          "orders"."state" NOT IN (\'cancelled_by_guest\',\'cancelled_by_host\',\'rejected\',\'expired\') AND
          "reservation_periods"."date" BETWEEN ? AND ?
         GROUP BY reservation_periods.date, orders.transactable_id) AS spots_taken_per_transactable_per_date
       GROUP BY transactable_id
       ) as min_spots_taken_per_transactable_during_date_period ON min_spots_taken_per_transactable_during_date_period.transactable_id = transactables.id', PlatformContext.current.instance.id, start_date.to_s, end_date.to_s]))
      .where('(COALESCE(min_spots_taken_per_transactable_during_date_period.min_qty, 0) < transactables.quantity OR min_spots_taken_per_transactable_during_date_period.number_of_days_booked <= ?)', (end_date - start_date).to_i)
  }

  scope :not_booked_absolute, lambda { |start_date, end_date|
    joins(ActiveRecord::Base.send(:sanitize_sql_array, ['LEFT OUTER JOIN (
       SELECT MAX(qty) as max_qty, transactable_id
       FROM (SELECT SUM(orders.quantity) as qty, orders.transactable_id, reservation_periods.date
         FROM "orders"
         INNER JOIN "reservation_periods" ON "reservation_periods"."reservation_id" = "orders"."id"
         WHERE
          "orders"."instance_id" = ? AND
          "orders"."deleted_at" IS NULL AND
          "orders"."state" NOT IN (\'cancelled_by_guest\',\'cancelled_by_host\',\'rejected\',\'expired\') AND
          "reservation_periods"."date" BETWEEN ? AND ?
         GROUP BY reservation_periods.date, orders.transactable_id) AS spots_taken_per_transactable_per_date
       GROUP BY transactable_id
       ) as min_spots_taken_per_transactable_during_date_period ON min_spots_taken_per_transactable_during_date_period.transactable_id = transactables.id', PlatformContext.current.instance.id, start_date.to_s, end_date.to_s]))
      .where('COALESCE(min_spots_taken_per_transactable_during_date_period.max_qty, 0) < transactables.quantity')
  }

  # see http://www.postgresql.org/docs/9.4/static/functions-array.html
  scope :only_opened_on_at_least_one_of, lambda { |days|
    # check overlap -> && operator
    # for now only regular booking are supported - fixed price transactables are just returned
    where('? = ANY (transactables.available_actions) OR transactables.opened_on_days @> \'{?}\'', 'event', days)
  }

  scope :only_opened_on_all_of, lambda { |days|
    # check if opened_on_days contains days -> @> operator
    # for now only regular booking are supported - fixed price transactables are just returned
    where('? = ANY (transactables.available_actions) OR transactables.opened_on_days @> \'{?}\'', 'event', days)
  }

  # TODO: change schedule
  scope :overlaps_schedule_start_date, lambda { |date|
    where("
      ((select count(*) from schedules where scheduable_id = transactables.id and scheduable_type = '#{self}' limit 1) = 0)
      OR
      (?::timestamp::date >= (select sr_start_datetime from schedules where scheduable_id = transactables.id and scheduable_type = '#{self}' limit 1)::timestamp::date)", date)
  }

  scope :order_by_array_of_ids, lambda { |listing_ids|
    listing_ids_decorated = listing_ids.each_with_index.map { |lid, i| "WHEN transactables.id=#{lid} THEN #{i}" }
    order("CASE #{listing_ids_decorated.join(' ')} END") if listing_ids.present?
  }

  scope :with_date, ->(date) { where(created_at: date) }
  scope :by_topic, ->(topic_ids) { includes(:transactable_topics).where(transactable_topics: { topic_id: topic_ids }) if topic_ids.present? }
  scope :seek_collaborators, -> { where(seek_collaborators: true) }
  scope :feed_not_followed_by_user, lambda { |current_user|
    where.not(id: current_user.feed_followed_transactables.pluck(:id))
  }

  # == Validations
  validates_with CustomValidators

  validates :currency, presence: true, allow_nil: false, currency: true
  validates :transactable_type, :action_type, presence: true
  validates :location, presence: true, unless: ->(record) { record.location_not_required }
  validates :photos, length: { minimum: 1 }, unless: ->(record) { record.photo_not_required || !record.transactable_type.enable_photo_required }
  validates :quantity, presence: true, numericality: { greater_than: 0 }, unless: ->(record) { record.action_type.is_a?(Transactable::PurchaseAction) }

  validates :topics, length: { minimum: 1 }, if: ->(record) { record.topics_required && !record.draft.present? }

  validates_associated :approval_requests, :action_type
  validates :name, length: { maximum: 255 }, allow_blank: true

  after_save :trigger_workflow_alert_for_added_collaborators, unless: ->(record) { record.draft? }

  delegate :latitude, :longitude, :postcode, :city, :suburb, :street, :country, to: :location_address, allow_nil: true

  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company
  delegate :formatted_address, :local_geocoding, :distance_from, :address, :postcode, :administrator=, to: :location, allow_nil: true
  delegate :hours_to_expiration, :hours_for_guest_to_confirm_payment,
           :custom_validators, :show_company_name, :display_additional_charges?, :auto_accept_invitation_as_collaborator?,
           :auto_seek_collaborators?, :favourable_pricing_rate, :default_availability_template,
           to: :transactable_type
  delegate :name, to: :creator, prefix: true
  delegate :to_s, to: :name
  delegate :schedule_availability, :next_available_occurrences, :book_it_out_available?,
           :exclusive_price_available?, :only_exclusive_price_available?, to: :enabled_event_booking, allow_nil: true
  delegate :first_available_date, :second_available_date, :availability_exceptions,
           :custom_availability_template?, :availability, :overnight_booking?, to: :enabled_time_based_booking, allow_nil: true
  delegate :open_on?, :open_now?, :bookable?, :has_price?, :hours_to_expiration,
           to: :action_type, allow_nil: true

  attr_accessor :distance_from_search_query, :photo_not_required, :enable_monthly,
                :enable_weekly, :enable_daily, :enable_hourly, :skip_activity_feed_event,
                :enable_weekly_subscription, :enable_monthly_subscription, :enable_deposit_amount,
                :scheduled_action_free_booking, :regular_action_free_booking, :location_not_required,
                :topics_required

  monetize :insurance_value_cents, with_model_currency: :currency, allow_nil: true

  state_machine :state, initial: :pending do
    event :start                 do transition pending: :in_progress; end
    event :finish                 do transition in_progress: :completed; end
    event :cancel                 do transition [:in_progress, :pending] => :cancelled; end

    before_transition in_progress: :cancelled, do: :check_expenses

    after_transition any => [:cancelled], do: :decline_reservations
    after_transition any => [:completed], do: :archive_orders
    after_transition any => [:cancelled] { |t| WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Cancelled, t.id) }
    after_transition any => [:completed] { |t| WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Completed, t.id) }
  end

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :scoped], scope: :instance
  def slug_candidates
    [
      :name,
      [:name, self.class.last.try(:id).to_i + 1],
      [:name, rand(1_000_000)]
    ]
  end

  def self.require_payout?
    return false unless current_instance
    !current_instance.test_mode? && current_instance.require_payout_information?
  end

  def self.current_instance
    PlatformContext.current.try(:instance)
  end

  def attachments_for_user(user)
    attachments.select { |attachment| attachment.accessible_to?(user) }
  end

  def availability_template
    time_based_booking.try(:availability_template) || location.try(:availability_template)
  end

  def validation_for(field_names)
    custom_validators.where(field_name: field_names)
  end

  def set_is_trusted
    self.enabled = enabled && is_trusted?
    true
  end

  def set_available_actions
    self.available_actions = action_type.pricings.pluck(:unit).uniq if action_type
  end

  def availability_for(date, start_min = nil, end_min = nil)
    if open_on?(date, start_min, end_min)
      # Return the number of free desks
      [quantity - desks_booked_on(date, start_min, end_min), 0].max
    else
      0
    end
  end

  # Maximum quantity available for a given date
  def quantity_for(_date)
    quantity
  end

  def administrator
    super.presence || creator
  end

  def desks_booked_on(date, start_minute = nil, end_minute = nil)
    scope = orders.confirmed.joins(:periods).where(reservation_periods: { date: date })

    if start_minute
      hourly_conditions = []
      hourly_values = []
      hourly_conditions << '(reservation_periods.start_minute IS NULL AND reservation_periods.end_minute IS NULL)'

      [start_minute, end_minute].compact.each do |minute|
        hourly_conditions << '(? BETWEEN reservation_periods.start_minute AND reservation_periods.end_minute)'
        hourly_values << minute
      end

      scope = scope.where(hourly_conditions.join(' OR '), *hourly_values)
    end

    scope.sum(:quantity)
  end

  def all_prices
    @all_prices ||= action_type ? action_type.pricings.map { |p| p.is_free_booking? ? 0 : p.price_cents } : []
  end

  def lowest_price_with_type(price_types = [])
    action_type.pricings_for_types(price_types).sort_by(&:price).first
  end

  # @return [Transactable::Pricing] object corresponding to the lowest available pricing for this transactable
  # @todo Remove lowest_price_with_type or ideally move this to decorator
  def lowest_price(available_price_types = [])
    lowest_price_with_type(available_price_types)
  end

  # @return [Transactable::Pricing] lowest price for this location (i.e. including service fees and mandatory additional charges)
  def lowest_full_price(available_price_types = [])
    lowest_price = lowest_price_with_type(available_price_types)

    if lowest_price.present?
      # If we set the full price on the original object it will have side effects for subsequent code using the pricing object
      lowest_price = lowest_price.dup

      full_price_cents = lowest_price.price
      unless lowest_price.service_fee_guest_percent.to_f.zero?
        full_price_cents *= (1 + lowest_price.service_fee_guest_percent / 100.0)
      end

      full_price_cents += Money.new(AdditionalChargeType.where(status: 'mandatory').sum(:amount_cents), full_price_cents.currency.iso_code)
      lowest_price.price = full_price_cents
    end

    lowest_price
  end

  def created_by?(user)
    user && user.admin? || user == creator
  end

  # @return [Boolean] whether there are any photos for this listing
  def has_photos?
    photos_metadata.try(:count).to_i > 0
  end

  def reserve!(reserving_user, dates, quantity, pricing = action_type.pricings.first)
    payment_method = PaymentMethod.manual.first
    reservation = Reservation.new(
      user: reserving_user,
      owner: reserving_user,
      quantity: quantity,
      transactable_pricing: pricing,
      transactable: self,
      currency: currency
    )
    reservation.build_payment(reservation.shared_payment_attributes.merge(payment_method: payment_method))
    dates.each do |date|
      raise ::DNM::PropertyUnavailableOnDate.new(date, quantity) unless available_on?(date, quantity)
      reservation.add_period(date)
    end
    reservation.save!
    reservation.activate!
    reservation
  end

  def dates_fully_booked
    orders.map(:date).select { |_d| fully_booked_on?(date) }
  end

  def fully_booked_on?(date)
    open_on?(date) && !available_on?(date)
  end

  # TODO: price per unit
  def available_on?(date, quantity = 1, start_min = nil, end_min = nil)
    quantity = 1 if transactable_type.action_price_per_unit?
    availability_for(date, start_min, end_min) >= quantity
  end

  def all_additional_charge_types_ids
    (additional_charge_types + transactable_type.try(:additional_charge_types) + instance.additional_charge_types).map(&:id)
  end

  def all_additional_charge_types
    AdditionalChargeType.where(id: all_additional_charge_types_ids).order(:status, :name)
  end

  def to_liquid
    @transactable_drop ||= TransactableDrop.new(decorate)
  end

  def self.xml_attributes(transactable_type = nil)
    csv_fields(transactable_type || PlatformContext.current.instance.transactable_types.first)
      .keys.reject { |k| k =~ /for_(\d*)_(\w*)_price_cents/ }.sort
  end

  def name_with_address
    [name, location.street].compact.join(' at ')
  end

  def order_attributes
    {
      currency_id: Currency.find_by(iso_code: currency).try(:id),
      company: company
    }
  end

  # @return [Integer, nil] days since the last order for the transactable or nil if no orders
  def last_booked_days
    last_reservation = orders.order('created_at DESC').first
    last_reservation ? ((Time.current.to_f - last_reservation.created_at.to_f) / 1.day.to_f).round : nil
  end

  def disable!
    self.enabled = false
    save(validate: false)
  end

  def disabled?
    !(enabled? && !payout_information_missing?)
  end

  def payout_information_missing?
    instance.require_payout? && !possible_payout?
  end

  def enable!
    self.enabled = true
    save(validate: false)
  end

  def approval_request_acceptance_cancelled!
    update_attribute(:enabled, false) unless is_trusted?
  end

  def approval_request_approved!
    update_attribute(:enabled, true) if is_trusted?
  end

  def approval_request_rejected!(approval_request_id)
    WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Rejected, id, approval_request_id)
  end

  def approval_request_questioned!(approval_request_id)
    WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Questioned, id, approval_request_id)
  end

  def self.csv_fields(transactable_type)
    transactable_type.action_types.map(&:pricings).flatten.each_with_object({}) do |pricing, hash|
      hash[:"for_#{pricing.units_to_s}_price_cents"] = "for_#{pricing.units_to_s}_price_cents".humanize
      hash
    end.merge(
      name: 'Name', description: 'Description',
      external_id: 'External Id', enabled: 'Enabled',
      confirm_reservations: 'Confirm reservations', capacity: 'Capacity', quantity: 'Quantity',
      listing_categories: 'Listing categories',
      currency: 'Currency', minimum_booking_minutes: 'Minimum booking minutes'
    ).reverse_merge(
      transactable_type.custom_attributes.shared.pluck(:name, :label).each_with_object({}) do |arr, hash|
        hash[arr[0].to_sym] = arr[1].presence || arr[0].humanize
        hash
      end
    )
  end

  def transactable_type_id
    self[:transactable_type_id] || transactable_type.try(:id)
  end

  def set_external_id
    update_column(:external_id, "manual-#{id}") if external_id.blank?
  end

  def reviews
    @reviews ||= Review.for_transactables(orders.pluck(:id), transactable_line_items.pluck(:id))
  end

  def has_reviews?
    !reviews.empty?
  end

  def question_average_rating
    @rating_answers_rating ||= RatingAnswer.where(review_id: reviews.map(&:id))
                                           .group(:rating_question_id).average(:rating)
  end

  def recalculate_average_rating!
    average_rating = reviews.average(:rating) || 0.0
    update(average_rating: average_rating)
  end

  # TODO: action rfq
  def action_rfq?
    super && transactable_type.action_rfq?
  end

  # @return [Boolean] whether PayPal Express Checkout is the marketplace's payment method
  # @todo Investigate whether this is still used/should be removed
  def express_checkout_payment?
    instance.payment_gateway(company.iso_country_code, currency).try(:express_checkout_payment?)
  end

  # TODO: to be deleted once we get rid of instance views
  def has_action?(*_args)
    action_rfq?
  end

  # @return [String] currency used for this transactable's pricings
  def currency
    self[:currency].presence || transactable_type.try(:default_currency)
  end

  def translation_namespace
    transactable_type.try(:translation_namespace)
  end

  def translation_namespace_was
    transactable_type.try(:translation_namespace_was)
  end

  def required?(attribute)
    RequiredFieldChecker.new(self, attribute).required?
  end

  def zone_utc_offset
    Time.now.in_time_zone(timezone).utc_offset / 3600
  end

  def timezone
    case transactable_type.timezone_rule
    when 'location' then location.try(:time_zone)
    when 'seller' then (creator || location.try(:creator) || company.try(:creator) || location.try(:company).try(:creator)).try(:time_zone)
    when 'instance' then instance.time_zone
    end.presence || Time.zone.name
  end

  def timezone_info
    I18n.t('activerecord.attributes.transactable.timezone_info', timezone: timezone) unless Time.zone.name == timezone
  end

  def get_error_messages
    msgs = []

    errors.each do |field|
      msgs += if field =~ /\.properties/
                errors.get(field)
              else
                errors.full_messages_for(field)
              end
    end
    msgs
  end

  # @return [Boolean] whether free booking is possible for the transactable
  def action_free_booking?
    action_type.is_free_booking?
  end

  def jsonapi_serializer_class_name
    'TransactableJsonSerializer'
  end

  %w(EventBooking TimeBasedBooking NoActionBooking PurchaseAction SubscriptionBooking).each do |class_name|
    define_method("#{class_name.underscore}?") { action_type.try(:type) == "Transactable::#{class_name}" }
  end

  # TODO: remove after switch to FormConfiguration
  def initialize_action_types
    transactable_type.action_types.enabled.each do |tt_action_type|
      next if action_types.any? { |at| at.transactable_type_action_type == tt_action_type }
      action_types.build(
        transactable_type_action_type: tt_action_type,
        type: "Transactable::#{tt_action_type.class.name.demodulize}"
      )
    end
    self.action_type ||= action_types.find(&:enabled) || action_types.first
    self.action_type.enabled = true
  end

  # TODO: remove after switch to FormConfiguration
  def initialize_default_availability_template
    if transactable_type.try(:default_availability_template_id).present?
      action_types.each do |at|
        if at.is_a?(Transactable::TimeBasedBooking)
          at.availability_template_id = transactable_type.default_availability_template_id if at.availability_template_id.blank?
        end
      end
    end
  end

  def self.custom_order(order)
    case order
    when /most recent/i
      order('transactables.created_at DESC')
    when /most popular/i
      # TODO: check most popular sort after followers are implemented
      order('transactables.followers_count DESC')
    when /collaborators/i
      group('transactables.id')
        .joins('LEFT OUTER JOIN transactable_collaborators tc ON transactables.id = tc.transactable_id AND (tc.approved_by_owner_at IS NOT NULL AND tc.approved_by_user_at IS NOT NULL AND tc.deleted_at IS NULL)')
        .order('count(tc.id) DESC')
    when /featured/i
      where(featured: true, draft: nil)
    when /pending/i
      where('(SELECT tc.id from transactable_collaborators tc WHERE tc.transactable_id = transactables.id AND tc.user_id = 6520 AND ( approved_by_user_at IS NULL OR approved_by_owner_at IS NULL) AND deleted_at IS NULL LIMIT 1) IS NOT NULL')
    else
      if PlatformContext.current.instance.is_community?
        order('transactables.followers_count DESC')
      else
        all
      end
    end
  end

  def cover_photo
    photos.first || Photo.new
  end

  def build_new_collaborator
    OpenStruct.new(email: nil)
  end

  def new_collaborators
    (@new_collaborators || []).empty? ? [OpenStruct.new(email: nil)] : @new_collaborators
  end

  def new_collaborators_attributes=(attributes)
    @new_collaborators = (attributes || {}).values.map { |c| c[:email] }.reject(&:blank?).uniq.map { |email| OpenStruct.new(email: email) }
  end

  def is_collaborator?(user)
    transactable_collaborators.approved.where(user: user).exists?
  end

  def collaborators_email_recipients
    approved_transactable_collaborators.includes(user: :notification_preference).select { |tc| u = tc.user; u.present? && (u.notification_preference.blank? || (u.notification_preference.email_frequency.eql?('immediately') && u.notification_preference.project_updates_enabled?)) }
  end

  def attachments_visible_for(user)
    ::SellerAttachment::Fetcher.new(user).attachments_for(self)
  end

  def message_context_object
    self
  end

  def custom_attributes_custom_validators
    @custom_attributes_custom_validators ||= { properties: transactable_type.custom_attributes_custom_validators }
  end

  private

  def set_seek_collaborators
    self.seek_collaborators = true
  end

  def check_expenses
    unless line_item_orders.with_state(:confirmed).all?(&:all_paid?)
      errors.add(:base, I18n.t('errors.transactable.cant_cancel'))
      return false
    end
    true
  end

  def archive_orders
    line_item_orders.with_state(:confirmed).map(&:complete!)
  end

  def close_request_for_quotes
    transactable_tickets.with_state(:open).each(&:resolve!)
    true
  end

  def set_possible_payout
    self.possible_payout = company.present? && company.merchant_accounts.verified.any? do |merchant_account|
      merchant_account.supports_currency?(currency) && merchant_account.payment_gateway.active_in_current_mode?
    end
    true
  end

  def set_currency
    self.currency = currency
    true
  end

  def set_activated_at
    self.activated_at = (enabled ? Time.current : nil) if enabled_changed?
    true
  end

  def set_enabled
    self.enabled = is_trusted? if enabled
    true
  end

  def set_confirm_reservations
    self.confirm_reservations = action_type.transactable_type_action_type.confirm_reservations if confirm_reservations.nil?
    true
  end

  def set_action_type
    self.action_type = action_types.find(&:enabled) if self.action_type.blank? || !self.action_type.valid?
  end

  def enabled_event_booking
    event_booking == action_type ? event_booking : nil
  end

  def enabled_time_based_booking
    time_based_booking == action_type ? time_based_booking : nil
  end

  def decline_reservations
    line_item_orders.unconfirmed.each(&:reject!)

    recurring_bookings.with_state(:unconfirmed, :confirmed, :overdued).each(&:host_cancel!)
  end

  def document_requirement_hidden?(attributes)
    attributes[:_destroy] = '1' if attributes['removed'] == '1'
    attributes['hidden'] == '1'
  end

  def should_create_sitemap_node?
    draft.nil? && enabled?
  end

  def should_update_sitemap_node?
    draft.nil? && enabled?
  end

  # Counter culture does not play along well (on destroy) with acts_as_paranoid
  def fix_counter_caches
    creator.update_column(:transactables_count, creator.listings.where(draft: nil).count) if creator && !creator.destroyed?
    true
  end

  # Counter culture does not play along well (on destroy) with acts_as_paranoid
  def fix_counter_caches_after_commit
    execute_after_commit { fix_counter_caches }
    true
  end

  def restore_photos
    photos.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', deleted_at - 30.seconds, deleted_at + 30.seconds).find_each do |photo|
      begin
        photo.restore(recursive: true)
      rescue
      end
    end
  end

  def restore_links
    links.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', deleted_at - 30.seconds, deleted_at + 30.seconds).find_each do |link|
      begin
        link.restore(recursive: true)
      rescue
      end
    end
  end

  def trigger_workflow_alert_for_added_collaborators
    return true if @new_collaborators.nil?
    @new_collaborators.each do |collaborator|
      collaborator_email = collaborator.email.try(:downcase)
      next if collaborator_email.blank?
      user = User.find_by(email: collaborator_email)
      next unless user.present?
      unless transactable_collaborators.for_user(user).exists?
        transactable_collaborators.create!(user: user, email: collaborator_email, approved_by_owner_at: Time.zone.now)
      end
    end
  end

  def restore_transactable_collaborators
    transactable_collaborators.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', deleted_at - 30.seconds, deleted_at + 30.seconds).find_each do |tc|
      begin
        tc.restore(recursive: true)
      rescue
      end
    end
  end

  class NotFound < ActiveRecord::RecordNotFound; end
end
