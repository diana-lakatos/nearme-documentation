class Transactable < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  include Impressionable
  include Searchable
  include SitemapService::Callbacks
  include SellerAttachments
    # == Helpers
  include Listing::Search
  include AvailabilityRule::TargetHelper
  include Categorizable
  include Approvable

  DEFAULT_ATTRIBUTES = %w(name description capacity)

  DATE_VALUES = ['today', 'yesterday', 'week_ago', 'month_ago', '3_months_ago', '6_months_ago']

  RENTAL_SHIPPING_TYPES = %w(no_rental delivery pick_up both).freeze

  PRICE_TYPES = [:hourly, :weekly, :daily, :monthly, :fixed, :exclusive, :weekly_subscription, :monthly_subscription]

  has_custom_attributes target_type: 'ServiceType', target_id: :transactable_type_id
  has_metadata accessors: [:photos_metadata]
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id, :listings_public], :location)

  has_many :customizations, as: :customizable
  has_many :additional_charge_types, as: :additional_charge_type_target
  has_many :availability_templates, as: :parent
  has_many :approval_requests, as: :owner, dependent: :destroy
  has_many :amenity_holders, as: :holder, dependent: :destroy, inverse_of: :holder
  has_many :amenities, through: :amenity_holders, inverse_of: :listings
  has_many :assigned_waiver_agreement_templates, as: :target
  has_many :billing_authorizations, as: :reference
  has_many :company_industries, through: :location
  has_many :document_requirements, as: :item, dependent: :destroy, inverse_of: :item
  has_many :inquiries, inverse_of: :listing
  has_many :impressions, :as => :impressionable, :dependent => :destroy
  has_many :photos, as: :owner, dependent: :destroy do
    def thumb
      (first || build).thumb
    end
  end
  has_many :attachments, -> { order(:id) }, class_name: 'SellerAttachment', as: :assetable
  has_many :recurring_bookings, inverse_of: :listing
  has_many :reservations, inverse_of: :listing
  has_many :transactable_tickets, as: :target, class_name: 'Support::Ticket'
  has_many :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many :waiver_agreement_templates, through: :assigned_waiver_agreement_templates
  has_many :wish_list_items, as: :wishlistable
  has_many :billing_authorizations, as: :reference
  has_many :inappropriate_reports, as: :reportable, dependent: :destroy
  belongs_to :transactable_type, -> { with_deleted }
  belongs_to :service_type, -> { with_deleted }, foreign_key: 'transactable_type_id'
  belongs_to :company, -> { with_deleted }, inverse_of: :listings
  belongs_to :location, -> { with_deleted }, inverse_of: :listings, touch: true
  belongs_to :instance, inverse_of: :listings
  belongs_to :creator, -> { with_deleted }, class_name: "User", inverse_of: :listings, counter_cache: true
  belongs_to :administrator, -> { with_deleted }, class_name: "User", inverse_of: :administered_listings
  belongs_to :availability_template
  has_one :dimensions_template, as: :entity

  has_one :location_address, through: :location
  has_one :schedule, as: :scheduable, dependent: :destroy
  has_one :upload_obligation, as: :item, dependent: :destroy

  accepts_nested_attributes_for :additional_charge_types, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :attachments, allow_destroy: true
  accepts_nested_attributes_for :availability_template
  accepts_nested_attributes_for :dimensions_template, allow_destroy: true
  accepts_nested_attributes_for :document_requirements, allow_destroy: true, reject_if: :document_requirement_hidden?
  accepts_nested_attributes_for :photos, allow_destroy: true
  accepts_nested_attributes_for :schedule, allow_destroy: true
  accepts_nested_attributes_for :upload_obligation
  accepts_nested_attributes_for :waiver_agreement_templates, allow_destroy: true
  accepts_nested_attributes_for :customizations, allow_destroy: true

  # == Callbacks
  before_destroy :decline_reservations
  before_validation :pass_timezone_to_schedule
  before_save :set_currency
  before_save :set_is_trusted
  before_validation :set_booking_type_for_free, :set_activated_at, :set_enabled, :nullify_not_needed_attributes,
    :set_confirm_reservations, :build_availability_template, :set_minimum_booking_minutes
  after_create :set_external_id
  after_save do
    if availability.try(:days_open).present?
      self.update_column(:opened_on_days, schedule_booking? ? nil : availability.days_open.sort)
    end
    true
  end
  after_destroy :close_request_for_quotes

  # == Scopes
  scope :featured, -> { where(featured: true) }
  scope :draft, -> { where('transactables.draft IS NOT NULL') }
  scope :active, -> { where('transactables.draft IS NULL') }
  scope :latest, -> { order("transactables.created_at DESC") }
  scope :visible, -> { where(:enabled => true) }
  scope :searchable, -> { active.visible }
  scope :for_transactable_type_id, -> transactable_type_id { where(transactable_type_id: transactable_type_id) }
  scope :for_groupable_transactable_types, -> { joins(:transactable_type).where('transactable_types.groupable_with_others = ?', true) }
  scope :filtered_by_price_types, -> price_types { where([(price_types - ['free']).map { |pt| "#{pt}_price_cents IS NOT NULL" }.join(' OR '),
                                                          ("transactables.action_free_booking=true" if price_types.include?('free'))].reject(&:blank?).join(' OR ')) }
  scope :filtered_by_custom_attribute, -> (property, values) { where("string_to_array((transactables.properties->?), ',') && ARRAY[?]", property, values) unless values.blank? }

  scope :not_booked_relative, -> (start_date, end_date) {
    joins(ActiveRecord::Base.send(:sanitize_sql_array, ['LEFT OUTER JOIN (
       SELECT MIN(qty) as min_qty, transactable_id, count(*) as number_of_days_booked
       FROM (SELECT SUM(reservations.quantity) as qty, reservations.transactable_id, reservation_periods.date
         FROM "reservations"
         INNER JOIN "reservation_periods" ON "reservation_periods"."reservation_id" = "reservations"."id"
         WHERE
          "reservations"."instance_id" = ? AND
          COALESCE("reservations"."booking_type", \'daily\') != \'hourly\' AND
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

  scope :overlaps_schedule_start_date, -> (date) {
    where("
      ((select count(*) from schedules where scheduable_id = transactables.id and scheduable_type = '#{self.to_s}' limit 1) = 0)
      OR
      (?::timestamp::date >= (select sr_start_datetime from schedules where scheduable_id = transactables.id and scheduable_type = '#{self.to_s}' limit 1)::timestamp::date)", date)
  }

  scope :order_by_array_of_ids, -> (listing_ids) {
    listing_ids_decorated = listing_ids.each_with_index.map {|lid, i| "WHEN transactables.id=#{lid} THEN #{i}" }
    order("CASE #{listing_ids_decorated.join(' ')} END") if listing_ids.present?
  }

  scope :with_date, ->(date) { where(created_at: date) }

  # == Validations
  validates_with PriceValidator
  validates_with CustomValidators

  validates :book_it_out_minimum_qty, :insurance_value, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :book_it_out_discount, numericality: {greater_than: 0, less_than: 100}, allow_blank: true
  validates :booking_type, inclusion: { in: ServiceType::BOOKING_TYPES }
  validates :currency, presence: true, allow_nil: false, currency: true
  validates :location, :transactable_type, presence: true
  validates :photos, length: {:minimum => 1}, unless: ->(record) { record.photo_not_required || !record.transactable_type.enable_photo_required }
  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :rental_shipping_type, inclusion: { in: RENTAL_SHIPPING_TYPES }
  validates_presence_of :dimensions_template, if: lambda { |record| ['delivery', 'both'].include?(record.rental_shipping_type) }
  validates_associated :approval_requests
  validates :name, length: { maximum: 255 }, allow_blank: true

  validate :check_book_it_out_minimum_qty, if: ->(record) { record.book_it_out_minimum_qty.present? }
  validate :booking_availability, if: ->(record) { record.overnight_booking? }

  delegate :latitude, :longitude, to: :location_address, allow_nil: true

  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company
  delegate :formatted_address, :local_geocoding, :distance_from, :address, :postcode, :administrator=, to: :location, allow_nil: true
  delegate :service_fee_guest_percent, :service_fee_host_percent, :hours_to_expiration, :hours_for_guest_to_confirm_payment,
    :custom_validators, :show_company_name, :skip_payment_authorization?, :display_additional_charges?, to: :transactable_type
  delegate :name, to: :creator, prefix: true
  delegate :to_s, to: :name
  delegate :favourable_pricing_rate, to: :transactable_type

  attr_accessor :distance_from_search_query, :photo_not_required, :enable_monthly,
    :enable_weekly, :enable_daily, :enable_hourly,
    :enable_weekly_subscription,:enable_monthly_subscription,
    :availability_template_attributes, :enable_exclusive_price, :enable_deposit_amount,
    :enable_book_it_out_discount, :scheduled_action_free_booking, :regular_action_free_booking

  monetize :daily_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :hourly_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :weekly_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :monthly_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :fixed_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :exclusive_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :insurance_value_cents, with_model_currency: :currency, allow_nil: true
  monetize :weekly_subscription_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :monthly_subscription_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :deposit_amount_cents, with_model_currency: :currency, allow_nil: true

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :scoped], scope: :instance
  def slug_candidates
    [
      :name,
      [:name, self.class.last.try(:id).to_i + 1],
      [:name, rand(1000000)]
    ]
  end

  def availability_template
    super || location.try(:availability_template)
  end

  def hide_defered_availability_rules?
    service_type.try(:hide_location_availability)
  end

  def validation_for(field_names)
    custom_validators.where(field_name: field_names)
  end

  def set_is_trusted
    self.enabled = self.enabled && is_trusted?
    true
  end

  def set_booking_type_for_free
    if transactable_type.booking_choices.one? && transactable_type.regular_booking_enabled? && transactable_type.available_price_types.none?
      self.booking_type ||= 'free'
      self.action_free_booking = true
    end
    true
  end

  def build_availability_template
    if availability_template_attributes.present?
      if availability_template_attributes["id"].present?
        self.availability_template.attributes = availability_template_attributes
      else
        availability_template_attributes.merge!({
          name: 'Custom transactable availability',
          parent: self
        })
        self.availability_template = AvailabilityTemplate.new(availability_template_attributes)
      end
    end
  end

  def open_on?(date, start_min = nil, end_min = nil)
    if schedule_booking?
      hour = start_min/60
      minute = start_min - (60 * hour)
      Time.use_zone(timezone) do
        t = Time.zone.parse("#{date} #{hour}:#{minute}")
        self.schedule.schedule.occurs_between?(t - 1.second, t) || self.schedule.schedule.occurs_on?(t)
      end
    else
      availability.try(:open_on?, date: date, start_minute: start_min, end_minute: end_min)
    end
  end

  def next_available_occurrences(number_of_occurrences = 10, params = {})
    return {} if schedule.nil?
    occurrences = []
    checks_to_be_performed = 100
    if params[:page].to_i <= 1
      @start_date = params[:start_date].try(:to_date).try(:beginning_of_day)
    else
      @start_date = Time.at(params[:last_occurrence].to_i)
    end
    time_now = Time.now.in_time_zone(timezone)
    @start_date = time_now if @start_date.nil? || @start_date < time_now

    end_date = params[:end_date].try(:to_date).try(:end_of_day)
    excluded_ranges = schedule.excluded_ranges_for(@start_date, end_date)
    loop do
      checks_to_be_performed -= 1
      next_occurrences = schedule.schedule.next_occurrences(number_of_occurrences, @start_date).uniq
      next_occurrences.each do |occurrence|
        if occurrence && excluded_ranges.none? { |r| r.cover?(occurrence) } && (!end_date || occurrence <= end_date)
          start_minute = occurrence.to_datetime.min.to_i + (60 * occurrence.to_datetime.hour.to_i)
          availability = self.quantity - desks_booked_on(occurrence.to_datetime, start_minute, start_minute)
          if availability > 0
            occurrences << { id: occurrence.to_i, text: I18n.l(occurrence.in_time_zone(timezone), format: :long), availability: availability.to_i, occures_at: occurrence }
          end
        end
        @start_date = occurrence
        break if occurrences.count == number_of_occurrences
      end
      break if occurrences.count >= number_of_occurrences || @start_date.nil? || checks_to_be_performed.zero? || (end_date && @start_date > end_date)
    end
    occurrences
  end

  def availability_for(date, start_min = nil, end_min = nil)
    if open_on?(date, start_min, end_min)
      # Return the number of free desks
      [self.quantity - desks_booked_on(date, start_min, end_min), 0].max
    else
      0
    end
  end

  def availability_exceptions
    availability_templates.map(&:future_availability_exceptions).flatten
  end

  # Maximum quantity available for a given date
  def quantity_for(date)
    self.quantity
  end

  def administrator
    super.presence || creator
  end

  def rental_shipping_type
    service_type.rental_shipping ? super : 'no_rental'
  end

  def desks_booked_on(date, start_minute = nil, end_minute = nil)
    scope = reservations.confirmed.joins(:periods).where(:reservation_periods => {:date => date})

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

  def all_prices
    @all_prices ||= PRICE_TYPES.map { |price| self.send("#{price}_price_cents") }.compact.reject(&:zero?)
  end

  def schedule_availability
    if schedule_booking?
      self.next_available_occurrences(500, {end_date: 6.months.from_now}).map{|o| o[:occures_at]} || []
    else
      []
    end
  end

  def subscription_variants
    { weekly: weekly_subscription_price_cents, monthly: monthly_subscription_price_cents }.select{ |k,v| v.to_i > 0 }.with_indifferent_access
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

  def lowest_full_price(available_price_types = [])
    lowest_full_price = nil
    lowest_price = lowest_price_with_type(available_price_types)

    if lowest_price.present?
      full_price_cents = lowest_price[0]

      if !service_fee_guest_percent.to_f.zero?
        full_price_cents = full_price_cents * (1 + service_fee_guest_percent / 100.0)
      end

      full_price_cents += Money.new(AdditionalChargeType.where(status: 'mandatory').sum(:amount_cents), full_price_cents.currency.iso_code)

      lowest_full_price = [full_price_cents, lowest_price[1]]
    end

    lowest_full_price
  end

  def null_price!
    PRICE_TYPES.map { |price|
      self.send(:"#{price}_price_cents=", nil) if self.respond_to?(:"#{price}_price_cents=")
    }
  end

  def price_for_subscription(period)
    subscription_variants[period]
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

  def reserve!(reserving_user, dates, quantity)
    payment_method  = PaymentMethod.manual.first
    reservation = reservations.build(:user => reserving_user, :quantity => quantity)
    reservation.calculate_prices
    reservation.build_payment({ payment_method: payment_method })
    dates.each do |date|
      raise ::DNM::PropertyUnavailableOnDate.new(date, quantity) unless available_on?(date, quantity)
      reservation.add_period(date)
    end
    reservation.save!
    reservation.activate!
    reservation
  end

  def dates_fully_booked
    reservations.map(:date).select { |d| fully_booked_on?(date) }
  end

  def fully_booked_on?(date)
    open_on?(date) && !available_on?(date)
  end

  def available_on?(date, quantity=1, start_min = nil, end_min = nil)
    quantity = 1 if transactable_type.action_price_per_unit?
    availability_for(date, start_min, end_min) >= quantity
  end

  def first_available_date
    time = Time.now.in_time_zone(timezone)
    date = time.to_date
    max_date = date + 31.days

    closed_at = self.availability.close_minute_for(date)

    if closed_at && (closed_at < (time.hour * 60 + time.min + minimum_booking_minutes))
      date = date + 1.day
    end

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
      booking_units_per_week
    elsif monthly_price_cents.to_i > 0
      booking_units_per_month
    else
      1
    end
  end

  def booking_days_per_week
    @booking_days_per_week ||= availability.try(:days_open).try(:length)
  end

  def booking_nights_per_week
    booking_days_per_week
  end

  def booking_units_per_week
    overnight_booking? ? booking_nights_per_week : booking_days_per_week
  end

  def booking_days_per_month
    @booking_days_per_month ||= transactable_type.days_for_monthly_rate.zero? ? booking_days_per_week * 4 : transactable_type.days_for_monthly_rate
  end

  def booking_nights_per_month
    transactable_type.days_for_monthly_rate.zero? ? booking_days_per_month - 1 : transactable_type.days_for_monthly_rate
  end

  def booking_units_per_month
    overnight_booking? ? booking_nights_per_month : booking_days_per_month
  end

  # Returns a hash of booking block sizes to prices for that block size.
  def prices_by_days
    if action_free_booking?
      {1 => 0.to_money}
    else
      Hash[
        [[1, daily_price], [booking_units_per_week, weekly_price], [booking_units_per_month, monthly_price]].
          reject { |size, price| !price || price.zero? }
      ]
    end
  end

  def all_additional_charge_types
    ids = (additional_charge_types + transactable_type.additional_charge_types + instance.additional_charge_types).map(&:id)
    AdditionalChargeType.where(id: ids).order(:status, :name)
  end

  def availability_status_between(start_date, end_date)
    AvailabilityRule::ListingStatus.new(self, start_date, end_date)
  end

  def hourly_availability_schedule(date)
    AvailabilityRule::HourlyListingStatus.new(self, date)
  end

  def to_liquid
    @transactable_drop ||= TransactableDrop.new(self.decorate)
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

  def approval_request_acceptance_cancelled!
    update_attribute(:enabled, false) unless is_trusted?
  end

  def approval_request_approved!
    update_attribute(:enabled, true) if is_trusted?
  end

  def approval_request_rejected!(approval_request_id)
    WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Rejected, self.id, approval_request_id)
  end

  def approval_request_questioned!(approval_request_id)
    WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Questioned, self.id, approval_request_id)
  end

  def self.csv_fields(transactable_type)
    transactable_type.pricing_options_long_period_names.inject({}) do |hash, price|
      hash[:"#{price}_price_cents"] = "#{price}_price_cents".humanize
      hash
    end.merge(
      name: 'Name', description: 'Description',
      external_id: 'External Id', enabled: 'Enabled',
      confirm_reservations: 'Confirm reservations', capacity: 'Capacity', quantity: 'Quantity',
      listing_categories: 'Listing categories', rental_shipping_type: "Rental shipping type",
      currency: 'Currency', minimum_booking_minutes: 'Minimum booking minutes',
      weekly_subscription_price_cents: 'Weekly subscription price cents',
      monthly_subscription_price_cents: 'Monthly subscription price cents',
      booking_type: "Booking type",
    ).reverse_merge(
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

  ServiceType::BOOKING_TYPES.each do |bt|
    define_method("#{bt}_booking?") do
      booking_type == bt
    end
  end

  def reviews
    @reviews ||= Review.for_reviewables(self.reservations.pluck(:id), 'Reservation')
  end

  def has_reviews?
    reviews.size > 0
  end

  def question_average_rating
    @rating_answers_rating ||= RatingAnswer.where(review_id: reviews.map(&:id))
      .group(:rating_question_id).average(:rating)
  end

  def recalculate_average_rating!
    average_rating = reviews.average(:rating) || 0.0
    self.update(average_rating: average_rating)
  end

  def book_it_out_available?
    schedule_booking? && transactable_type.action_book_it_out? && book_it_out_discount.to_i > 0
  end

  def exclusive_price_available?
    transactable_type.action_exclusive_price? && exclusive_price.to_f > 0
  end

  def only_exclusive_price_available?
    exclusive_price_available? && fixed_price.to_f.zero?
  end

  def check_book_it_out_minimum_qty
    if book_it_out_minimum_qty > quantity
      errors.add(:book_it_out_minimum_qty, I18n.t('activerecord.errors.models.transactable.attributes.book_it_out_minimum_qty'))
    end
  end

  def action_rfq?
    super && self.transactable_type.action_rfq?
  end

  def express_checkout_payment?
    instance.payment_gateway(company.iso_country_code, currency).try(:express_checkout_payment?)
  end

  def possible_delivery?
    rental_shipping_type.in?(['delivery', 'both'])
  end

  # TODO: to be deleted once we get rid of instance views
  def has_action?(*args)
    action_rfq?
  end

  def currency
    read_attribute(:currency).presence || transactable_type.try(:default_currency)
  end

  def translation_namespace
    service_type.try(:translation_namespace)
  end

  def translation_namespace_was
    service_type.try(:translation_namespace_was)
  end

  def required?(attribute)
    RequiredFieldChecker.new(self, attribute).required?
  end

  def zone_utc_offset
    Time.now.in_time_zone(timezone).utc_offset / 3600
  end

  def timezone
    case self.transactable_type.timezone_rule
    when 'location' then self.location.try(:time_zone)
    when 'seller' then (self.creator || self.location.try(:creator) || self.company.try(:creator) || self.location.try(:company).try(:creator)).try(:time_zone)
    when 'instance' then self.instance.time_zone
    end.presence || Time.zone.name
  end

  def timezone_info
    unless Time.zone.name == timezone
      I18n.t('activerecord.attributes.transactable.timezone_info', timezone: timezone)
    end
  end

  def custom_availability_template?
    availability_template.try(:custom_for_transactable?)
  end

  def scheduled_action_free_booking
    self.action_free_booking
  end

  def regular_action_free_booking
    self.action_free_booking
  end

  private

  def close_request_for_quotes
    self.transactable_tickets.each { |ticket| ticket.resolve! }
    true
  end

  def set_currency
    self.currency = currency
  end

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

  def set_minimum_booking_minutes
    self.minimum_booking_minutes ||= transactable_type.minimum_booking_minutes
  end

  def set_confirm_reservations
    if confirm_reservations.nil?
      self.confirm_reservations = transactable_type.availability_options["confirm_reservations"]["default_value"]
    end
    true
  end

  def nullify_not_needed_attributes
    self.deposit_amount_cents = nil unless enable_deposit_amount == '1'
    if schedule_booking?
      self.exclusive_price_cents = nil unless enable_exclusive_price == '1'
      self.book_it_out_discount = self.book_it_out_minimum_qty = nil unless enable_book_it_out_discount == '1'
      nullify_prices(exclude: [:fixed, :exclusive])
      self.action_hourly_booking = self.action_daily_booking = nil
      self.action_free_booking = nil if self.has_price?
      self.action_schedule_booking = true
    elsif subscription_booking?
      self.action_schedule_booking = self.action_hourly_booking = self.action_daily_booking = self.action_free_booking = nil
      nullify_prices(exclude: [:weekly_subscription, :monthly_subscription])
    else
      nullify_prices(only: [:fixed, :exclusive, :weekly_subscription, :monthly_subscription])
      self.action_schedule_booking = false
      self.schedule = nil
    end

    true
  end

  def nullify_prices(exclude: [], only: nil)
    prices = only || (PRICE_TYPES - Array(exclude).map(&:to_sym))
    prices.each do |price|
      self.send("#{price}_price=", Money.new(nil, currency))
    end
  end

  def decline_reservations
    reservations.unconfirmed.each do |r|
      r.reject!
    end

    recurring_bookings.with_state(:unconfirmed, :confirmed, :overdued).each do |booking|
      booking.host_cancel!
    end
  end

  def document_requirement_hidden?(attributes)
    attributes.merge!(_destroy: '1') if attributes['removed'] == '1'
    attributes['hidden'] == '1'
  end

  def pass_timezone_to_schedule
    schedule.try(:timezone=, timezone)
  end

  def should_create_sitemap_node?
    draft.nil? && enabled?
  end

  def should_update_sitemap_node?
    draft.nil? && enabled?
  end

  def booking_availability
    if monthly_price_cents.to_i > 0 && availability.days_open.length < 7
      errors.add(:monthly_price, I18n.t('activerecord.errors.models.transactable.attributes.cant_set_montly_price'))
    end
    unless (availability && availability.consecutive_days_open?)
      errors.add(:availability_template, I18n.t('activerecord.errors.models.transactable.attributes.no_consecutive_days'))
    end
  end

  class NotFound < ActiveRecord::RecordNotFound; end
end

