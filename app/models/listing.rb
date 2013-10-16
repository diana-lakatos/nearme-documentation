class Listing < ActiveRecord::Base
  has_paper_trail
  # == Associations
  has_many :reservations,
    dependent: :destroy

  has_many :photos, dependent: :destroy, as: :content do
    def thumb
      (first || build).thumb
    end
  end

  has_many :inquiries

  has_many :availability_rules,
    :order => 'day ASC',
    :as => :target,
    :dependent => :destroy

  has_one :company, through: :location
  belongs_to :location, inverse_of: :listings, with_deleted: true
  belongs_to :listing_type

  accepts_nested_attributes_for :availability_rules, :allow_destroy => true
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # == Scopes
  scope :featured, where(%{ (select count(*) from "photos" where content_id = "listings".id AND content_type = 'Listing') > 0  }).
    includes(:photos).order(%{ random() }).limit(5)
  scope :draft,    where('listings.draft IS NOT NULL')
  scope :active,   where('listings.draft IS NULL')
  scope :latest,   order("listings.created_at DESC")
  scope :visible,  where(:enabled => true)
  scope :searchable, active.visible
  scope :filtered_by_listing_types_ids,  lambda { |listing_types_ids| where('listings.listing_type_id IN (?)', listing_types_ids) }

  # == Callbacks
  after_save :notify_user_about_change
  after_destroy :notify_user_about_change

  # == Validations
  validates_presence_of :location, :name, :quantity, :listing_type_id
  validates_presence_of :description
  validates_numericality_of :quantity, greater_than: 0
  validates_length_of :description, :maximum => 250
  validates_with PriceValidator
  validates :hourly_reservations, :inclusion => { :in => [true, false], :message => "must be selected" }, :allow_nil => false
  validates :photos, :length => { :minimum => 1 }, :unless => :photo_not_required

  # == Helpers
  include Search
  include AvailabilityRule::TargetHelper

  PRICE_TYPES = [:hourly, :weekly, :daily, :monthly]

  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company
  delegate :instance, :amenities, :currency, :formatted_address, :notify_user_about_change,
    :local_geocoding, :latitude, :longitude, :distance_from, :address, to: :location,
    allow_nil: true
  delegate :creator, :creator=, to: :location
  delegate :administrator, :to => :location, :allow_nil => true
  delegate :name, to: :creator, prefix: true
  delegate :service_fee_percent, to: :location, allow_nil: true
  delegate :to_s, to: :name

  attr_accessible :confirm_reservations, :location_id, :quantity, :name, :description,
    :availability_template_id, :availability_rules_attributes, :defer_availability_rules,
    :free, :photos_attributes, :listing_type_id, :hourly_reservations, :price_type, :draft, :enabled

  attr_accessor :distance_from_search_query, :photo_not_required

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

  def has_price?
    PRICE_TYPES.map { |price|
      self["#{price}_price_cents"]
    }.compact.any? { |price| !price.zero? }
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

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def reserve!(request_context, reserving_user, dates, quantity)
    reservation = reservations.build(:user => reserving_user, :quantity => quantity)
    dates.each do |date|
      raise ::DNM::PropertyUnavailableOnDate.new(date, quantity) unless available_on?(date, quantity)
      reservation.add_period(date)
    end

    reservation.save!

    if reservation.listing.confirm_reservations?
      ReservationMailer.notify_host_with_confirmation(request_context, reservation).deliver
      ReservationMailer.notify_guest_with_confirmation(request_context, reservation).deliver
    else
      ReservationMailer.notify_host_without_confirmation(request_context, reservation).deliver
      ReservationMailer.notify_guest_of_confirmation(request_context, reservation).deliver
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

  def to_liquid
    ListingDrop.new(self)
  end

  def self.xml_attributes
    [:name, :description, :quantity, :hourly_price_cents, :daily_price_cents, :weekly_price_cents, :monthly_price_cents]
  end

  def name_with_address
    [name, location.street].compact.join(" at ")
  end

end

class NullListing
  def description
    ""
  end
end
