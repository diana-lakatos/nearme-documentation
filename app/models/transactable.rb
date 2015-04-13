class Transactable < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  class NotFound < ActiveRecord::RecordNotFound;
  end
  include Impressionable
  has_metadata accessors: [:photos_metadata]
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id, :listings_public], :location)

  has_custom_attributes target_type: 'TransactableType', target_id: :transactable_type_id

  has_many :availability_rules, -> { order 'day ASC' }, as: :target, dependent: :destroy, inverse_of: :target
  has_many :approval_requests, as: :owner, dependent: :destroy
  has_many :amenity_holders, as: :holder, dependent: :destroy, inverse_of: :holder
  has_many :amenities, through: :amenity_holders, inverse_of: :listings
  has_many :assigned_waiver_agreement_templates, as: :target
  has_many :billing_authorizations, as: :reference
  has_many :categories_transactables
  has_many :categories, through: :categories_transactables
  has_many :company_industries, through: :location
  has_many :document_requirements, as: :item, dependent: :destroy, inverse_of: :item
  has_many :inquiries, inverse_of: :listing
  has_many :impressions, :as => :impressionable, :dependent => :destroy
  has_many :photos, dependent: :destroy, inverse_of: :listing do
    def thumb
      (first || build).thumb
    end
  end
  has_many :recurring_bookings, inverse_of: :listing
  has_many :reservations, inverse_of: :listing
  has_many :transactable_tickets, as: :target, class_name: 'Suppport::Ticket'
  has_many :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many :waiver_agreement_templates, through: :assigned_waiver_agreement_templates
  has_many :wish_list_items, as: :wishlistable

  belongs_to :transactable_type, inverse_of: :transactables
  belongs_to :company, inverse_of: :listings
  belongs_to :location, inverse_of: :listings, touch: true
  belongs_to :instance, inverse_of: :listings
  belongs_to :creator, class_name: "User", inverse_of: :listings, counter_cache: true
  belongs_to :administrator, class_name: "User", inverse_of: :administered_listings

  has_one :location_address, through: :location
  has_one :schedule, as: :scheduable
  has_one :upload_obligation, as: :item, dependent: :destroy

  accepts_nested_attributes_for :availability_rules, allow_destroy: true
  accepts_nested_attributes_for :photos, allow_destroy: true
  accepts_nested_attributes_for :waiver_agreement_templates, allow_destroy: true
  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :document_requirements, allow_destroy: true, reject_if: :document_requirement_hidden?
  accepts_nested_attributes_for :upload_obligation
  accepts_nested_attributes_for :schedule

  before_destroy :decline_reservations

  # == Scopes
  scope :featured, -> { where(%{ (select count(*) from "photos" where transactable_id = "listings".id) > 0  }).
                        includes(:photos).order(%{ random() }).limit(5) }
  scope :draft, -> { where('transactables.draft IS NOT NULL') }
  scope :active, -> { where('transactables.draft IS NULL') }
  scope :latest, -> { order("transactables.created_at DESC") }
  scope :visible, -> { where(:enabled => true) }
  scope :searchable, -> { active.visible }
  scope :for_transactable_type_id, -> transactable_type_id { where(transactable_type_id: transactable_type_id) }
  scope :for_groupable_transactable_types, -> { joins(:transactable_type).where('transactable_types.groupable_with_others = ?', true) }
  scope :filtered_by_price_types, -> price_types { where([(price_types - ['free']).map { |pt| "#{pt}_price_cents IS NOT NULL" }.join(' OR '),
                                                          ("action_free_booking=true" if price_types.include?('free'))].reject(&:blank?).join(' OR ')) }
  scope :where_attribute_has_value, -> (attr, value) { where("properties @> '#{attr}=>#{value}'") }
  scope :filtered_by_custom_attribute, -> (property, values) { where("string_to_array((transactables.properties->?), ',') && ARRAY[?]", property, values) unless values.blank? }

  scope :not_booked_relative, -> (start_date, end_date) {
    joins(ActiveRecord::Base.send(:sanitize_sql_array, ['LEFT OUTER JOIN (
       SELECT MIN(qty) as min_qty, transactable_id, count(*) as number_of_days_booked
       FROM (SELECT SUM(reservations.quantity) as qty, reservations.transactable_id, reservation_periods.date
         FROM "reservations"
         INNER JOIN "reservation_periods" ON "reservation_periods"."reservation_id" = "reservations"."id"
         WHERE
          "reservations"."instance_id" = ? AND
          "reservations"."deleted_at" IS NULL AND
          "reservations"."state" NOT IN (\'cancelled_by_guest\',\'cancelled_by_host\',\'rejected\',\'expired\') AND
          "reservation_periods"."date" BETWEEN ? AND ?
         GROUP BY reservation_periods.date, reservations.transactable_id) AS spots_taken_per_transactable_per_date
       GROUP BY transactable_id
       ) as min_spots_taken_per_transactable_during_date_period ON min_spots_taken_per_transactable_during_date_period.transactable_id = transactables.id', PlatformContext.current.instance.id, start_date.to_s, end_date.to_s]))
      .where('(COALESCE(min_spots_taken_per_transactable_during_date_period.min_qty, 0) < transactables.quantity OR min_spots_taken_per_transactable_during_date_period.number_of_days_booked <= ?)', (end_date - start_date).to_i)
  }

  scope :not_booked_absolute, -> (start_date, end_date) {
    joins(ActiveRecord::Base.send(:sanitize_sql_array, ['LEFT OUTER JOIN (
       SELECT MAX(qty) as max_qty, transactable_id
       FROM (SELECT SUM(reservations.quantity) as qty, reservations.transactable_id, reservation_periods.date
         FROM "reservations"
         INNER JOIN "reservation_periods" ON "reservation_periods"."reservation_id" = "reservations"."id"
         WHERE
          "reservations"."instance_id" = ? AND
          "reservations"."deleted_at" IS NULL AND
          "reservations"."state" NOT IN (\'cancelled_by_guest\',\'cancelled_by_host\',\'rejected\',\'expired\') AND
          "reservation_periods"."date" BETWEEN ? AND ?
         GROUP BY reservation_periods.date, reservations.transactable_id) AS spots_taken_per_transactable_per_date
       GROUP BY transactable_id
       ) as min_spots_taken_per_transactable_during_date_period ON min_spots_taken_per_transactable_during_date_period.transactable_id = transactables.id', PlatformContext.current.instance.id, start_date.to_s, end_date.to_s]))
      .where('COALESCE(min_spots_taken_per_transactable_during_date_period.max_qty, 0) < transactables.quantity')
  }

  # see http://www.postgresql.org/docs/9.4/static/functions-array.html
  scope :only_opened_on_at_least_one_of, -> (days) {
    # check overlap -> && operator
    # for now only regular booking are supported - fixed price transactables are just returned
    where('transactables.action_schedule_booking = ? OR transactables.opened_on_days && \'{?}\'', true, days)
  }

  scope :only_opened_on_all_of, -> (days) {
    # check if opened_on_days contains days -> @> operator
    # for now only regular booking are supported - fixed price transactables are just returned
    where('transactables.action_schedule_booking = ? OR transactables.opened_on_days @> \'{?}\'', true, days)
  }

  # == Callbacks
  before_validation :set_activated_at, :set_enabled, :nullify_not_needed_attributes

  # == Validations
  validates_presence_of :location, :transactable_type
  validates_with PriceValidator
  validates :photos, length: {:minimum => 1}, unless: ->(record) { record.photo_not_required || !record.transactable_type.enable_photo_required }
  validates_inclusion_of :booking_type, in: TransactableType::BOOKING_TYPES
  validates :quantity, presence: true
  validates :quantity, numericality: {greater_than: 0}
  validates :book_it_out_minimum_qty, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :book_it_out_discount, numericality: {greater_than: 0, less_than: 100}, allow_blank: true
  validate :check_book_it_out_minimum_qty, if: ->(record) { record.book_it_out_minimum_qty.present? }

  after_save :set_external_id
  after_save { self.update_column(:opened_on_days, availability.days_open.sort) }

  # == Helpers
  include Listing::Search
  include AvailabilityRule::TargetHelper

  PRICE_TYPES = [:hourly, :weekly, :daily, :monthly, :fixed]

  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company
  delegate :currency, :formatted_address, :local_geocoding,
    :latitude, :longitude, :distance_from, :address, :postcode, :administrator=, to: :location, allow_nil: true
  delegate :service_fee_guest_percent, :service_fee_host_percent, :hours_to_expiration, :minimum_booking_minutes, to: :transactable_type
  delegate :name, to: :creator, prefix: true
  delegate :to_s, to: :name
  delegate :favourable_pricing_rate, to: :transactable_type

  attr_accessor :distance_from_search_query, :photo_not_required

  monetize :daily_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :hourly_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :weekly_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :monthly_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :fixed_price_cents, with_model_currency: :currency, allow_nil: true

  # Defer to the parent Location for availability rules unless this Listing has specific
  # rules.
  def availability
    if defer_availability_rules? && location
      location.availability
    else
      super # See: AvailabilityRule::TargetHelper#availability
    end
  end

  # Trigger clearing of all existing availability rules on save
  def defer_availability_rules=(clear)
    if clear.to_i == 1
      availability_rules.each(&:mark_for_destruction)
    end
  end

  def display_defered_availability_rules?
    respond_to?(:defer_availability_rules) && !transactable_type.skip_location?
  end

  def set_custom_defaults
    self.enabled = is_trusted? if self.enabled.nil?
  end

  # Are we deferring availability rules to the Location?
  def defer_availability_rules
    availability_rules.to_a.reject(&:marked_for_destruction?).empty?
  end

  alias_method :defer_availability_rules?, :defer_availability_rules

  def open_on?(date, start_min = nil, end_min = nil)
    if schedule_booking?
      hour = start_min/60
      minute = start_min - (60 * hour)
      # to datetime is to have date in UTC otherwise we won't be able to check in IceCube schedule :|
      self.schedule.schedule.occurs_at?("#{date} #{hour}:#{minute}".to_datetime.to_time.utc)
    else
      availability.open_on?(:date => date, :start_minute => start_min, :end_minute => end_min)
    end
  end

  def next_available_occurrences(number_of_occurrences = 10)
    occurences = {}
    occurence = Time.now
    checks_to_be_performed = 100
    loop do
      checks_to_be_performed -= 1
      occurence = schedule.try(:schedule).try(:next_occurrences, 10, occurence).try(:first)
      if occurence
        start_minute = occurence.to_datetime.min.to_i + (60 * occurence.to_datetime.hour.to_i)
        availability = self.quantity - desks_booked_on(occurence.to_datetime, start_minute, start_minute)
        if availability > 0
          occurences[occurence.to_datetime.to_i.to_s] = { date: occurence, availability: availability }
        end
      end
      break if occurences.count == number_of_occurrences || occurence.nil? || checks_to_be_performed.zero?
    end
    occurences
  end

  def availability_for(date, start_min = nil, end_min = nil)
    if open_on?(date, start_min, end_min)
      # Return the number of free desks
      [self.quantity - desks_booked_on(date, start_min, end_min), 0].max
    else
      0
    end
  end

  # Maximum quantity available for a given date
  def quantity_for(date)
    self.quantity
  end

  def administrator
    super.presence || creator
  end

  def desks_booked_on(date, start_minute = nil, end_minute = nil)
    scope = reservations.not_rejected_or_cancelled.joins(:periods).where(:reservation_periods => {:date => date})

    if start_minute
      hourly_conditions = []
      hourly_values = []
      hourly_conditions << "(reservation_periods.start_minute IS NULL AND reservation_periods.end_minute IS NULL)"

      [start_minute, end_minute].compact.each do |minute|
        hourly_conditions << "(? BETWEEN reservation_periods.start_minute AND reservation_periods.end_minute)"
        hourly_values << minute
      end

      scope = scope.where(hourly_conditions.join(' OR '), *hourly_values)
    end

    scope.sum(:quantity)
  end

  def has_price?
    PRICE_TYPES.map { |price| self.send("#{price}_price_cents") }.compact.any? { |price| !price.zero? }
  end

  #TODO refactor
  def lowest_price_with_type(available_price_types = [])
    PRICE_TYPES.reject { |price|
      !available_price_types.empty? && !available_price_types.include?(price.to_s)
    }.map { |price|
      [self.send("#{price}_price"), price]
    }.reject { |p| p[0].to_f.zero? }.sort { |a, b| a[0] <=> b[0] }.first
  end

  # TODO: remove lowest_price_with_type or ideally move this to decorator
  def lowest_price(available_price_types = [])
    lowest_price_with_type(available_price_types)
  end

  def null_price!
    PRICE_TYPES.map { |price|
      self.send(:"#{price}_price_cents=", nil) if self.respond_to?(:"#{price}_price_cents=")
    }
  end

  def desks_available?(date)
    quantity > reservations.on(date).count
  end

  def created_by?(user)
    user && user.admin? || user == creator
  end

  def inquiry_from!(user, attrs = {})
    inquiries.build(attrs).tap do |i|
      i.inquiring_user = user
      i.save!
    end
  end

  def has_photos?
    photos_metadata.try(:count).to_i > 0
  end

  def to_param
    "#{id}-#{properties["name"].parameterize}"
  rescue
    id
  end

  def reserve!(reserving_user, dates, quantity)
    reservation = reservations.build(:user => reserving_user, :quantity => quantity)
    dates.each do |date|
      raise ::DNM::PropertyUnavailableOnDate.new(date, quantity) unless available_on?(date, quantity)
      reservation.add_period(date)
    end

    reservation.save!

    if reservation.listing.confirm_reservations?
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, reservation.id)
    else
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithAutoConfirmation, reservation.id)
    end
    reservation
  end

  def dates_fully_booked
    reservations.map(:date).select { |d| fully_booked_on?(date) }
  end

  def fully_booked_on?(date)
    open_on?(date) && !available_on?(date)
  end

  def available_on?(date, quantity=1, start_min = nil, end_min = nil)
    availability_for(date, start_min, end_min) >= quantity
  end

  def first_available_date
    date = Date.tomorrow

    max_date = date + 31.days
    date = date + 1.day until availability_for(date) > 0 || date==max_date
    date
  end

  def second_available_date
    date = first_available_date + 1.day

    max_date = date + 31.days
    date = date + 1.day until availability_for(date) > 0 || date==max_date
    date
  end

  # Number of minimum consecutive booking days required for this listing
  def minimum_booking_days
    if action_free_booking? || (action_hourly_booking? && hourly_price_cents.to_i > 0) || daily_price_cents.to_i > 0 || (daily_price_cents.to_i + weekly_price_cents.to_i + monthly_price_cents.to_i).zero?
      1
    elsif weekly_price_cents.to_i > 0
      booking_days_per_week
    elsif monthly_price_cents.to_i > 0
      booking_days_per_month
    else
      1
    end
  end

  def booking_days_per_week
    @booking_days_per_week ||= availability.days_open.length
  end

  def booking_days_per_month
    @booking_days_per_month ||= transactable_type.days_for_monthly_rate.zero? ? booking_days_per_week * 4 : transactable_type.days_for_monthly_rate
  end

  # Returns a hash of booking block sizes to prices for that block size.
  def prices_by_days
    if action_free_booking?
      {1 => 0.to_money}
    else
      Hash[
        [[1, daily_price], [booking_days_per_week, weekly_price], [booking_days_per_month, monthly_price]]
      ].reject { |size, price| !price || price.zero? }
    end
  end

  def availability_status_between(start_date, end_date)
    AvailabilityRule::ListingStatus.new(self, start_date, end_date)
  end

  def hourly_availability_schedule(date)
    AvailabilityRule::HourlyListingStatus.new(self, date)
  end

  def to_liquid
    TransactableDrop.new(self)
  end

  def self.xml_attributes(transactable_type = nil)
    self.csv_fields(transactable_type || PlatformContext.current.instance.transactable_types.first).keys.sort
  end

  def name_with_address
    [name, location.street].compact.join(" at ")
  end

  def last_booked_days
    last_reservation = reservations.order('created_at DESC').first
    last_reservation ? ((Time.current.to_f - last_reservation.created_at.to_f) / 1.day.to_f).round : nil
  end

  def disable!
    self.enabled = false
    self.save(validate: false)
  end

  def disabled?
    !enabled?
  end

  def enable!
    self.enabled = true
    self.save(validate: false)
  end

  def approval_request_templates
    @approval_request_templates ||= PlatformContext.current.instance.approval_request_templates.for("Transactable")
  end

  def is_trusted?
    if approval_request_templates.count > 0
      self.approval_requests.approved.count > 0
    else
      if self.location.present?
        self.location.is_trusted?
      elsif self.company.present?
        self.company.is_trusted?
      elsif self.creator.present?
        self.creator.is_trusted?
      else
        # Not tied to anything, so it's trusted
        true
      end
    end
  end

  def approval_request_acceptance_cancelled!
    update_attribute(:enabled, false) unless is_trusted?
  end

  def approval_request_approved!
    update_attribute(:enabled, true) if is_trusted?
  end

  def self.csv_fields(transactable_type)
    transactable_type.pricing_options_long_period_names.inject({}) do |hash, price|
      hash[:"#{price}_price_cents"] = "#{price}_price_cents".humanize
      hash
    end.merge({external_id: 'External Id', enabled: 'Enabled'}).reverse_merge(
      transactable_type.custom_attributes.shared.pluck(:name, :label).inject({}) do |hash, arr|
        hash[arr[0].to_sym] = arr[1].presence || arr[0].humanize
        hash
      end
    )
  end

  def transactable_type_id
    read_attribute(:transactable_type_id) || transactable_type.try(:id)
  end

  def set_external_id
    self.update_column(:external_id, "manual-#{id}") if self.external_id.blank?
  end

  def bookable?
    !schedule_booking? || (schedule_booking? && schedule.present? && next_available_occurrences(1).any?)
  end

  TransactableType::BOOKING_TYPES.each do |bt|
    define_method("#{bt}_booking?") do
      booking_type == bt
    end
  end

  def reviews
    @reviews ||= Review.where(object: 'product', reviewable_type: 'Reservation', reviewable_id: self.reservations.pluck(:id))
  end

  def has_reviews?
    reviews.count > 0
  end

  def question_average_rating
    @rating_answers_rating ||= RatingAnswer.where(review_id: reviews.pluck(:id))
      .group(:rating_question_id).average(:rating)
  end

  def recalculate_average_rating!
    average_rating = reviews.average(:rating) || 0.0
    self.update(average_rating: average_rating)
  end

  def book_it_out_available?
    schedule_booking? && transactable_type.action_book_it_out? && book_it_out_discount.to_i > 0
  end

  def check_book_it_out_minimum_qty
    if book_it_out_minimum_qty > quantity
      errors.add(:book_it_out_minimum_qty, I18n.t('activerecord.errors.models.transactable.attributes.book_it_out_minimum_qty'))
    end
  end

  def action_rfq?
    super && self.transactable_type.action_rfq?
  end

  # TODO: to be deleted once we get rid of instance views
  def has_action?(*args)
    action_rfq?
  end

  private

  def set_activated_at
    if enabled_changed?
      self.activated_at = (enabled ? Time.current : nil)
    end
    true
  end

  def set_enabled
    self.enabled = is_trusted? if self.enabled
    true
  end

  def nullify_not_needed_attributes
    if schedule_booking?
      self.hourly_price = self.daily_price = self.weekly_price = self.monthly_price = nil
      self.action_hourly_booking = self.action_daily_booking = self.action_free_booking = nil
    else
      self.fixed_price = nil
      self.action_schedule_booking = nil
    end
    true
  end

  def decline_reservations
    reservations.unconfirmed.each do |r|
      r.reject!
    end
  end

  def document_requirement_hidden?(attributes)
    attributes.merge!(_destroy: '1') if attributes['removed'] == '1'
    attributes['hidden'] == '1'
  end
end

