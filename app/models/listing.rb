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

  # === Callbacks

  validates_presence_of :location, :name, :description, :quantity, :listing_type_id
  validates_numericality_of :quantity
  validates_length_of :description, :maximum => 250
  validates_with PriceValidator

  attr_accessible :confirm_reservations, :location_id, :quantity, :rating_average, :rating_count,
    :name, :description, :daily_price, :weekly_price, :monthly_price,
    :daily_price_cents, :weekly_price_cents, :monthly_price_cents, :availability_template_id, 
    :availability_rules_attributes, :defer_availability_rules, :free,
    :photos_attributes, :listing_type_id


  delegate :to_s, to: :name


  monetize :daily_price_cents, :allow_nil => true
  monetize :weekly_price_cents, :allow_nil => true
  monetize :monthly_price_cents, :allow_nil => true


  acts_as_paranoid

  scope :featured, where(%{ (select count(*) from "photos" where content_id = "listings".id AND content_type = 'Listing') > 0  }).
    includes(:photos).order(%{ random() }).limit(5)

  scope :latest,   order("listings.created_at DESC")

  include Search
  include AvailabilityRule::TargetHelper
  accepts_nested_attributes_for :availability_rules, :allow_destroy => true
  accepts_nested_attributes_for :photos, :allow_destroy => true

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


  def open_on?(date)
    availability.open_on?(:date => date)
  end

  def availability_for(date)
    if open_on?(date)
      # Return the number of free desks
      [self.quantity - desks_booked_on(date), 0].max
    else
      0
    end
  end

  # Maximum quantity available for a given date
  def quantity_for(date)
    self.quantity
  end

  def desks_booked_on(date)
    reservations.not_rejected_or_cancelled.joins(:periods).where(:reservation_periods => { :date => date }).sum(:quantity)
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
      (daily_price_cents.to_f + weekly_price_cents.to_f + monthly_price_cents.to_f) == 0.0
    else
      @marked_free
    end
  end
  alias_method :free, :free?


  def free=(free_flag)
    @marked_free = free_flag
    if free_flag.present? && free_flag
      daily_price = nil
      weekly_price = nil
      monthly_price = nil
    end
  end

  def enable_daily
    !persisted? || self.daily_price_cents.present?
  end

  def enable_weekly
    !persisted? || self.weekly_price_cents.present?
  end

  def enable_monthly
    !persisted? || self.monthly_price_cents.present?
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

  def available_on?(date, quantity=1)
    availability_for(date) >= quantity
  end

  def first_available_date
    date = Date.today + 1.day
    max_date = date + 31.days
    date = date + 1.day until availability_for(date) > 0 || date==max_date
    date
  end

  def schedule(weeks = 1)
    schedule = {}

    # Build a hash of all week days and their default availabilities
    weeks.times do |offset|
      today  = Date.today + offset.weeks
      monday = today.weekend? ? today.next_week : today.beginning_of_week
      friday = monday + 4
      week   = monday..friday

      week.each do |day|
        schedule[day] = availability_for(day)
      end
    end

    schedule
  end

end

class NullListing
  def description
    ""
  end
end
