class Transactable < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  class NotFound < ActiveRecord::RecordNotFound; end
  has_metadata :accessors => [:listing_type_name, :photos_metadata]
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id], :location)

  has_many :reservations, dependent: :destroy

  has_many :photos, dependent: :destroy do
    def thumb
      (first || build).thumb
    end
  end

  has_many :inquiries

  has_many :availability_rules,
    :order => 'day ASC',
    :as => :target,
    :dependent => :destroy

  has_many :user_messages, as: :thread_context

  belongs_to :company
  belongs_to :location, inverse_of: :listings
  belongs_to :listing_type
  belongs_to :instance
  belongs_to :creator, class_name: "User"
  belongs_to :administrator, class_name: "User"

  has_many :amenity_holders, as: :holder, dependent: :destroy
  has_many :amenities, through: :amenity_holders

  has_many :reviews, :through => :reservations

  accepts_nested_attributes_for :availability_rules, :allow_destroy => true
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # == Scopes
  scope :featured, where(%{ (select count(*) from "photos" where transactable_id = "listings".id) > 0  }).
    includes(:photos).order(%{ random() }).limit(5)
  scope :draft,    where('transactables.draft IS NOT NULL')
  scope :active,   where('transactables.draft IS NULL')
  scope :latest,   order("transactables.created_at DESC")
  scope :visible,  where(:enabled => true)
  scope :searchable, active.visible
  scope :filtered_by_listing_types_ids,  lambda { |listing_types_ids| where('transactables.listing_type_id IN (?)', listing_types_ids) if listing_types_ids }
  scope :filtered_by_price_types,  lambda { |price_types| where(price_types.map{|pt| "(properties->'#{pt}_price_cents') IS NOT NULL"}.join(' OR  ')) if price_types }

  # == Callbacks
  after_initialize :set_defaults
  before_validation :set_activated_at

  # == Validations
  validates :name, length: { maximum: 50 }
  validates_presence_of :location, :name, :quantity, :listing_type_id
  validates_presence_of :description
  validates_numericality_of :quantity, greater_than: 0, only_integer: true
  validates_length_of :description, :maximum => 250
  validates_with PriceValidator
  validates :hourly_reservations, :inclusion => { :in => [true, false], :message => "must be selected" }, :allow_nil => false
  validates :photos, :length => { :minimum => 1 }, :unless => :photo_not_required



  # == Helpers
  include Listing::Search
  include AvailabilityRule::TargetHelper

  PRICE_TYPES = [:hourly, :weekly, :daily, :monthly]

  serialize :properties, ActiveRecord::Coders::Hstore
  hstore :properties, :accessors => {
    quantity: :integer, availability_rules_text: :text, confirm_reservations: :boolean, delta: :boolean, daily_price_cents: :integer,
    weekly_price_cents: :integer, monthly_price_cents: :integer, hourly_reservations: :boolean, hourly_price_cents: :integer,
    minimum_booking_minutes: :integer, external_id: :string, free: :boolean, last_request_photos_sent_at: :datetime,
    rank: :integer, capacity: :integer }

  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company
  delegate :currency, :formatted_address, :local_geocoding,
    :latitude, :longitude, :distance_from, :address, :postcode, :administrator=, to: :location, allow_nil: true
  delegate :service_fee_guest_percent, :service_fee_host_percent, to: :location, allow_nil: true
  delegate :name, to: :creator, prefix: true
  delegate :to_s, to: :name

  attr_accessible :confirm_reservations, :location_id, :quantity, :name, :description,
    :availability_template_id, :availability_rules_attributes, :defer_availability_rules,
    :free, :photos_attributes, :listing_type_id, :hourly_reservations, :price_type, :draft, :enabled,
    :last_request_photos_sent_at, :activated_at, :amenity_ids, :rank, :capacity

  attr_accessor :distance_from_search_query, :photo_not_required

  PRICE_TYPES.each do |price|
    # Flag each price type as a Money attribute.
    # @see rails-money
    monetize "#{price}_price_cents", :allow_nil => true

    # Mark price fields as attr-accessible
    attr_accessible "#{price}_price_cents", "#{price}_price"
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
    return if self.persisted?
    self.quantity ||= 1
    self.confirm_reservations = true if self.confirm_reservations.nil?
    self.delta = true if self.delta.nil?
    self.free = false if self.free.nil?
    self.enabled = true if self.enabled.nil?
    self.rank ||= 0
    self.listings_public = true if self.listings_public.nil?
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
      self.free = false
      self.hourly_reservations = false
    when PRICE_TYPES[0] #Hourly
      self.free = false
      self.hourly_reservations = true
    when :free
      self.null_price!
      self.free = true
      self.hourly_reservations = false
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
      self.send "#{price}_price_cents=", nil
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
    "#{id}-#{name.parameterize}"
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
    else
      multiple = if weekly_price_cents.to_i > 0
        1
      elsif monthly_price_cents.to_i > 0
        4
      else
        1
      end

      booking_days_per_week*multiple
    end
  end

  def booking_days_per_week
    availability.days_open.length
  end

  # Returns a hash of booking block sizes to prices for that block size.
  def prices_by_days
    if free?
      { 1 => 0.to_money }
    else
      block_size = booking_days_per_week
      Hash[
        [[1, daily_price], [block_size, weekly_price], [4*block_size, monthly_price]]
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
    [:name, :description, :quantity, :hourly_price_cents, :daily_price_cents, :weekly_price_cents, :monthly_price_cents]
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

  private
  def set_activated_at
    if enabled_changed?
      self.activated_at = (enabled ? Time.current : nil)
    end
  end
end

