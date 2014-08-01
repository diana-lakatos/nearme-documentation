class Transactable < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  class NotFound < ActiveRecord::RecordNotFound; end
  has_metadata :accessors => [:photos_metadata]
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id, :listings_public], :location)

  include TransactableType::CustomAttributesCaster

  has_many :reservations, dependent: :destroy, :inverse_of => :listing
  has_many :recurring_bookings, dependent: :destroy, :inverse_of => :listing
  has_many :photos, dependent: :destroy, :inverse_of => :listing do
    def thumb
      (first || build).thumb
    end
  end
  has_many :inquiries, :inverse_of => :listing
  has_many :availability_rules, -> { order 'day ASC' }, :as => :target, :dependent => :destroy, inverse_of: :target
  has_many :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many :confidential_files, as: :owner
  belongs_to :transactable_type, inverse_of: :transactables
  belongs_to :company, :inverse_of => :listings
  belongs_to :location, inverse_of: :listings
  belongs_to :instance, inverse_of: :listings
  belongs_to :creator, class_name: "User", :inverse_of => :listings
  belongs_to :administrator, class_name: "User", :inverse_of => :administered_listings

  has_many :amenity_holders, as: :holder, dependent: :destroy, inverse_of: :holder
  has_many :amenities, through: :amenity_holders, inverse_of: :listings
  has_one :location_address, through: :location

  has_many :reviews, :through => :reservations, inverse_of: :listings
  has_many :company_industries, through: :location

  accepts_nested_attributes_for :availability_rules, :allow_destroy => true
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # == Scopes
  scope :featured, -> {where(%{ (select count(*) from "photos" where transactable_id = "listings".id) > 0  }).
                       includes(:photos).order(%{ random() }).limit(5) }
  scope :draft,    -> { where('transactables.draft IS NOT NULL') }
  scope :active,   -> { where('transactables.draft IS NULL') }
  scope :latest,   -> { order("transactables.created_at DESC") }
  scope :visible,  -> { where(:enabled => true) }
  scope :searchable, -> { active.visible }
  scope :filtered_by_listing_types_ids,  -> listing_types_ids { where("(transactables.properties->'listing_type') IN (?)", listing_types_ids) if listing_types_ids }
  scope :filtered_by_price_types,  -> price_types { where(price_types.map{|pt| "(properties->'#{pt}_price_cents') IS NOT NULL"}.join(' OR  ')) if price_types }
  scope :filtered_by_attribute_values,  -> attribute_values { where("(transactables.properties->'filterable_attribute') IN (?)", attribute_values) if attribute_values }
  scope :where_attribute_has_value, -> (attr, value) { where("properties @> '#{attr}=>#{value}'")}

  # == Callbacks
  before_validation :set_activated_at
  before_validation :set_enabled

  # == Validations
  validates_presence_of :location, :transactable_type
  validates_with PriceValidator
  validates_with TransactableTypeAttributeValidator
  validates :photos, :length => { :minimum => 1 }, :unless => :photo_not_required

  # used to avoid initializing the same data over and over again if we know it won't change, for example
  # for Transactable.all we will just re-use array that sits in memory. Defining as class level instance variable,
  # just in case to avoid potential issues with inheritance
  @transactable_type_attributes_as_array = {}
  @transactable_type_attributes_cache_update_at = {}
  class << self
    attr_accessor :transactable_type_attributes_as_array, :transactable_type_attributes_cache_update_at
  end

  def initialize(*args)
    if args[0]
      @attributes_to_be_applied = args[0].select { |k, v| ![:id, :transactable_type_id, :transactable_type].include?(k.to_sym) }.with_indifferent_access
      args[0] = args[0].select { |k, v| [:id, :transactable_type_id, :transactable_type].include?(k.to_sym) }.with_indifferent_access
    end
    super(*args)
  end

  # == Helpers
  include Listing::Search
  include AvailabilityRule::TargetHelper

  PRICE_TYPES = [:hourly, :weekly, :daily, :monthly]

  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company
  delegate :currency, :formatted_address, :local_geocoding,
    :latitude, :longitude, :distance_from, :address, :postcode, :administrator=, to: :location, allow_nil: true
  delegate :service_fee_guest_percent, :service_fee_host_percent, to: :location, allow_nil: true
  delegate :name, to: :creator, prefix: true
  delegate :to_s, to: :name
  delegate :transactable_type_attributes, :favourable_pricing_rate, to: :transactable_type

  # attr_accessible :location_id, :availability_template_id,
  #   :availability_rules_attributes, :defer_availability_rules, :free,
  #   :photos_attributes, :hourly_reservations, :price_type, :draft, :enabled,
  #   :last_request_photos_sent_at, :activated_at, :amenity_ids, :rank, :transactable_type_id,
  #   :transactable_type, :photo_ids

  attr_accessor :distance_from_search_query, :photo_not_required

  after_initialize :apply_transactable_type_settings

  def apply_transactable_type_settings
    set_custom_attributes
    set_defaults if self.new_record?
    self.assign_attributes(@attributes_to_be_applied) if @attributes_to_be_applied.present?
  end

  def hourly_reservations?
    nil
  end

  def free?
    nil
  end

  PRICE_TYPES.each do |price|
    # Flag each price type as a Money attribute.
    # @see rails-money
    define_method("#{price}_price_cents") do
      nil
    end
    monetize "#{price}_price_cents", :allow_nil => true

    # Mark price fields as attr-accessible
    # attr_accessible "#{price}_price_cents", "#{price}_price"
  end

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

  def set_defaults
    self.enabled = is_trusted? if self.enabled.nil?
    transactable_type_attributes_names_default_values_hash.each do |key, value|
      send(:"#{key}=", value) if send(key).nil?
    end
  end

  # Are we deferring availability rules to the Location?
  def defer_availability_rules
    availability_rules.reject(&:marked_for_destruction?).empty?
  end
  alias_method :defer_availability_rules?, :defer_availability_rules

  def open_on?(date, start_min = nil, end_min = nil)
    availability.open_on?(:date => date, :start_minute => start_min, :end_minute => end_min)
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
    scope = reservations.not_rejected_or_cancelled.joins(:periods).where(:reservation_periods => { :date => date })

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

  def price_type=(price_type)
    case price_type.to_sym
    when PRICE_TYPES[2] #Daily
      self.free = false if self.respond_to?(:free=)
      self.hourly_reservations = false if self.respond_to?(:hourly_reservations=)
    when PRICE_TYPES[0] #Hourly
      self.free = false if self.respond_to?(:free=)
      self.hourly_reservations = true
    when :free
      self.null_price!
      self.free = true
      self.hourly_reservations = false if self.respond_to?(:hourly_reservations=)
    else
      errors.add(:price_type, 'no pricing type set')
    end
  end

  def price_type
    if free?
      :free
    elsif hourly_reservations?
      PRICE_TYPES[0] #Hourly
    else
      PRICE_TYPES[2] #Daily
    end

  end

  def lowest_price_with_type(available_price_types = [])
    PRICE_TYPES.reject{ |price|
      !available_price_types.empty? && !available_price_types.include?(price.to_s)
    }.map { |price|
      [self.send("#{price}_price"), price]
    }.reject{|p| p[0].to_f.zero?}.sort{|a, b| a[0] <=> b[0]}.first
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
      ReservationMailer.notify_host_with_confirmation(reservation).deliver
      ReservationMailer.notify_guest_with_confirmation(reservation).deliver
    else
      ReservationMailer.notify_host_without_confirmation(reservation).deliver
      ReservationMailer.notify_guest_of_confirmation(reservation).deliver
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

  # Number of minimum consecutive booking days required for this listing
  def minimum_booking_days
    if free? || hourly_reservations? || daily_price_cents.to_i > 0 || (daily_price_cents.to_i + weekly_price_cents.to_i + monthly_price_cents.to_i).zero?
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
    @booking_days_per_month ||= transactable_type.days_for_monthly_rate.zero? ? booking_days_per_week * 4  : transactable_type.days_for_monthly_rate
  end

  # Returns a hash of booking block sizes to prices for that block size.
  def prices_by_days
    if free?
      { 1 => 0.to_money }
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

  def self.xml_attributes
    self.csv_fields(PlatformContext.current.instance.transactable_types.first).keys.sort
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

  def is_trusted?
    if PlatformContext.current.instance.onboarding_verification_required
      self.confidential_files.accepted.count > 0 || self.location.try(:is_trusted?)
    else
      true
    end
  end

  def confidential_file_acceptance_cancelled!
    update_attribute(:enabled, false) unless is_trusted?
  end

  def confidential_file_accepted!
    update_attribute(:enabled, true) if is_trusted?
  end

  def self.csv_fields(transactable_type)
    { external_id: 'External Id', enabled: 'Enabled' }.reverse_merge(
      transactable_type.transactable_type_attributes.public.pluck(:name, :label).inject({}) do |hash, arr|
        hash[arr[0].to_sym] = arr[1].presence || arr[0].humanize
        hash
      end
    )
  end

  # invoked when transactable type attribute changes
  def self.clear_transactable_type_attributes_cache
    if self.transactable_type_attributes_cache_update_at[TransactableType.pluck(:id).first]
      transactable_type_ids = TransactableTypeAttribute.with_changed_attributes(self.transactable_type_attributes_cache_update_at[TransactableType.pluck(:id).first]).uniq.pluck(:transactable_type_id)
      transactable_type_ids.each do |transactable_type_id|
        self.transactable_type_attributes_as_array[transactable_type_id] = nil
      end
    end
  end

  def self.get_transactable_type_attributes_as_array(tt_id)
    if !self.transactable_type_attributes_as_array[tt_id]
      self.transactable_type_attributes_cache_update_at[tt_id] = Time.now.utc
      self.transactable_type_attributes_as_array[tt_id] = TransactableTypeAttribute.find_as_array(tt_id)
    end
    self.transactable_type_attributes_as_array[tt_id]
  end

  def transactable_type_attributes_as_array
    self.class.get_transactable_type_attributes_as_array(transactable_type_id)
  end

  def transactable_type_id
    read_attribute(:transactable_type_id) || transactable_type.id
  end

  def transactable_type_attributes_names_default_values_hash
    @transactable_type_attributes_names_default_values_hash ||= transactable_type_attributes_as_array.inject({}) do |hstore_attrs, attr_array|
      hstore_attrs[attr_array[0].to_sym] = attr_array[2]
      hstore_attrs
    end
  end

  def transactable_type_attributes_names_types_hash
    @transactable_type_attributes_names_types_hash ||= transactable_type_attributes_as_array.inject({}) do |hstore_attrs, attr_array|
      hstore_attrs[attr_array[0].to_sym] = attr_array[1].to_sym
      hstore_attrs
    end
  end

  def self.public_transactable_type_attributes_names(tt_id)
    self.get_transactable_type_attributes_as_array(tt_id).map { |attr_array| attr_array[3] ? attr_array[0].to_sym : nil }
  end

  private

  def set_activated_at
    if enabled_changed?
      self.activated_at = (enabled ? Time.current : nil)
    end
  end

  def set_enabled
    self.enabled = is_trusted? if self.enabled
  end

end

