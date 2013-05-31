class Listing < ActiveRecord::Base
  # == Associations
  has_many :reservations,
    dependent: :destroy

  has_many :photos,  as: :content, dependent: :destroy do
    def thumb
      (first || build).thumb
    end
  end

  has_many :inquiries

  has_many :availability_rules,
    :as => :target,
    :dependent => :destroy

  has_one :company, through: :location
  belongs_to :location, inverse_of: :listings
  belongs_to :listing_type

  accepts_nested_attributes_for :availability_rules, :allow_destroy => true
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # == Scopes
  scope :featured, where(%{ (select count(*) from "photos" where content_id = "listings".id AND content_type = 'Listing') > 0  }).
    includes(:photos).order(%{ random() }).limit(5)

  scope :latest,   order("listings.created_at DESC")

  # == Callbacks
  before_validation :clear_irrelevant_prices
  after_save :notify_user_about_change
  after_destroy :notify_user_about_change

  # == Validations
  validates_presence_of :location, :name, :description, :quantity, :listing_type_id
  validates_numericality_of :quantity
  validates_length_of :description, :maximum => 250
  validates_with PriceValidator

  # == Helpers
  include Search
  include AvailabilityRule::TargetHelper

  PRICE_TYPES = [:hourly, :weekly, :daily, :monthly]

  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company
  delegate :address, :amenities, :currency, :formatted_address,
    :local_geocoding, :latitude, :longitude, :distance_from, to: :location,
    allow_nil: true
  delegate :creator, :creator=, to: :location
  delegate :name, to: :creator, prefix: true
  delegate :notify_user_about_change, :to => :location, :allow_nil => true
  delegate :to_s, to: :name

  attr_accessible :confirm_reservations, :location_id, :quantity, :rating_average, :rating_count,
    :name, :description, :availability_template_id, :availability_rules_attributes, :defer_availability_rules,
    :free, :photos_attributes, :listing_type_id, :hourly_reservations

  PRICE_TYPES.each do |price|
    # Flag each price type as a Money attribute.
    # @see rails-money
    monetize "#{price}_price_cents", :allow_nil => true

    # Mark price fields as attr-accessible
    attr_accessible "#{price}_price_cents", "#{price}_price"
  end

  acts_as_paranoid

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

  def free?
    !has_price?
  end
  alias_method :free, :free?

  def has_price?
    PRICE_TYPES.map { |price|
      self["#{price}_price_cents"]
    }.compact.any? { |price| !price.zero? }
  end

  def free=(free_flag)
    return unless [true, "1"].include?(free_flag)

    self.hourly_price = nil
    self.daily_price = nil
    self.weekly_price = nil
    self.monthly_price = nil
  end

  def rate_for_user(rating, user)
    raise "Cannot rate unsaved listing" if new_record?
    r = ratings.find_or_initialize_by_user_id user.id
    r.rating = rating
    r.save
  end

  def rating_for(user)
    ratings.where(user_id: user.id).pluck(:rating).first
  end

  def desks_available?(date)
    quantity > reservations.on(date).count
  end

  def created_by?(user)
    user && user.admin? || user == creator
  end

  def inquiry_from!(user, attrs = {})
    i = inquiries.build(attrs)
    i.inquiring_user = user
    i.save!; i
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def reserve!(reserving_user, dates, quantity)
    reservation = reservations.build(
      :user => reserving_user,
      :quantity => quantity
    )

    dates.each do |date|
      raise DNM::PropertyUnavailableOnDate.new(date, quantity) unless available_on?(date, quantity)
      reservation.add_period(date)
    end

    reservation.save!
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
    date = Date.today + 1.day

    unless hourly_reservations?
      max_date = date + 31.days
      date = date + 1.day until availability_for(date) > 0 || date==max_date
    end

    date
  end

  # Number of minimum consecutive booking days required for this listing
  def minimum_booking_days
    if free? || hourly_reservations? || daily_price_cents.to_i > 0
      1
    else
      multiple = if weekly_price_cents.to_i > 0
        1
      elsif monthly_price_cents.to_i > 0
        4
      end

      booking_days_per_week*multiple
    end
  end

  def minumum_booking_minutes
    (super || 60) if hourly_reservations?
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

  def price_schedule
    if hourly_reservations?
      {
        :hourly => {
          1 => hourly_price,
          :minimum_minutes => minimum_booking_minutes
        }
      }
    else
      { :daily => prices_by_days }
    end
  end

  def availability_status_between(start_date, end_date)
    AvailabilityRule::ListingStatus.new(self, start_date, end_date)
  end

  def hourly_availability_schedule(date)
    AvailabilityRule::HourlyListingStatus.new(self, date)
  end

  private

  def clear_irrelevant_prices
    if hourly_reservations?
      self.daily_price = nil
      self.weekly_price = nil
      self.monthly_price = nil
    else
      self.hourly_price = nil
    end
  end
end

class NullListing
  def description
    ""
  end
end
