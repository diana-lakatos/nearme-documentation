class Listing < ActiveRecord::Base

  # Period constants for listing costs

  has_many :reservations,
    dependent: :destroy

  has_many :photos,  as: :content, dependent: :destroy do
    def thumb
      (first || build).thumb
    end
  end

  PRICE_PERIODS = {
    :free => nil,
    :day => 'day'
  }

  MINUTES_IN_DAY = 1440
  MINUTES_IN_WEEK = 10080
  MINUTES_IN_MONTH = 43200
  has_many :ratings,
    as: :content,
    dependent: :destroy


  has_many :inquiries

  has_one :company, through: :location
  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company

  belongs_to :location, inverse_of: :listings
  belongs_to :listing_type
  delegate :address, :amenities, :currency, :formatted_address,
    :local_geocoding, :latitude, :longitude, :distance_from, to: :location,
    allow_nil: true


  delegate :creator, :creator=, to: :location
  delegate :name, to: :creator, prefix: true


  has_many :availability_rules,
    :as => :target,
    :dependent => :destroy

  before_validation :remove_disabled_prices

  validates_presence_of :location, :name, :description, :quantity, :listing_type_id
  validates_numericality_of :quantity
  validates_length_of :description, :maximum => 250
  validates_with PriceValidator


  attr_accessible :confirm_reservations, :location_id, :quantity, :rating_average, :rating_count,
    :name, :description, :daily_price, :weekly_price, :monthly_price,
    :daily_price_cents, :weekly_price_cents, :monthly_price_cents, :availability_template_id, 
    :availability_rules_attributes, :defer_availability_rules, :free,
    :photos_attributes, :listing_type_id, :enable_daily, :enable_weekly, :enable_monthly, :enable_hourly,
    :hourly_reservations, :hourly_price, :hourly_price_cents

  attr_accessor :enable_daily, :enable_weekly, :enable_monthly, :enable_hourly

  after_save :notify_user_about_change
  after_destroy :notify_user_about_change

  delegate :notify_user_about_change, :to => :location, :allow_nil => true
  delegate :to_s, to: :name


  monetize :daily_price_cents, :allow_nil => true
  monetize :weekly_price_cents, :allow_nil => true
  monetize :monthly_price_cents, :allow_nil => true
  monetize :hourly_price_cents, :allow_nil => true


  acts_as_paranoid

  scope :featured, where(%{ (select count(*) from "photos" where content_id = "listings".id AND content_type = 'Listing') > 0  }).
    includes(:photos).order(%{ random() }).limit(5)

  scope :latest,   order("listings.created_at DESC")

  include Search
  include AvailabilityRule::TargetHelper
  accepts_nested_attributes_for :availability_rules, :allow_destroy => true
  accepts_nested_attributes_for :photos, :allow_destroy => true

  def enable_hourly
    @enable_hourly || price_enabled_by_default?(hourly_price)
  end

  def enable_daily
    @enable_daily || price_enabled_by_default?(daily_price)
  end
    
  def enable_weekly
    @enable_weekly || price_enabled_by_default?(weekly_price)
  end
    
  def enable_monthly
    @enable_monthly || price_enabled_by_default?(monthly_price)
  end

  def price_enabled_by_default?(price)
    # only prices greater than 0 are enabled
    price.to_f > 0
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

  def remove_disabled_prices
    self.daily_price_cents = nil if !enable_daily || daily_price.to_f.zero?
    self.weekly_price_cents = nil if !enable_weekly || weekly_price.to_f.zero?
    self.monthly_price_cents = nil if !enable_monthly || monthly_price.to_f.zero?
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

  def prices
    [daily_price, weekly_price, monthly_price]
  end

  def period_prices
    # day = 1440 minutes, week = 10080 minutes, month = 43200 minutes
    {MINUTES_IN_DAY => daily_price, MINUTES_IN_WEEK => weekly_price, MINUTES_IN_MONTH => monthly_price}
  end

  def price_period
    if free?
      PRICE_PERIODS[:free]
    else
      PRICE_PERIODS[:day]
    end
  end

  def free?
    if persisted?
      !has_price?
    else
      @marked_free
    end
  end
  alias_method :free, :free?

  def has_price?
    !(hourly_price_cents.to_f + daily_price_cents.to_f + weekly_price_cents.to_f + monthly_price_cents.to_f).zero?
  end


  def free=(free_flag)
    @marked_free = free_flag && free_flag != "0"
    if @marked_free
      self.hourly_price = nil
      self.daily_price = nil
      self.weekly_price = nil
      self.monthly_price = nil
    end
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

end

class NullListing
  def description
    ""
  end
end
