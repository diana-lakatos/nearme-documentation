class Listing < ActiveRecord::Base

  # Period constants for listing costs
  PRICE_PERIODS = {
    :free => nil,
    :day => 'day'
  }
  MINUTES_IN_DAY = 1440
  MINUTES_IN_WEEK = 10080
  MINUTES_IN_MONTH = 43200

  has_many :feeds, dependent: :delete_all
  has_many :reservations, dependent: :destroy
  has_many :reservations, dependent: :delete_all
  has_many :photos,  as: :content, dependent: :destroy do
    def thumb
      (first || build).thumb
    end
  end
  has_many :ratings, as: :content, dependent: :destroy
  has_many :unit_prices, dependent: :destroy

  has_many :inquiries

  has_one :company, through: :location
  belongs_to :location

  belongs_to :creator, class_name: "User"

  has_many :availability_rules, :as => :target

  validates_presence_of :location_id, :creator_id, :name, :description, :quantity
  validates_inclusion_of :confirm_reservations, :in => [true, false]
  validates_numericality_of :quantity

  attr_accessible :confirm_reservations, :location_id, :quantity, :rating_average, :rating_count,
                  :creator_id, :name, :description, :daily_price, :weekly_price, :monthly_price,
                  :availability_template_id, :availability_rules_attributes, :defer_availability_rules

  delegate :name, :description, to: :company, prefix: true, allow_nil: true
  delegate :url, to: :company
  delegate :address, :amenities, :currency, :formatted_address, :local_geocoding, :organizations, :required_organizations, :latitude,
    :longitude, :distance_from, to: :location, allow_nil: true

  delegate :to_s, to: :name


  acts_as_paranoid

  scope :featured, where(%{ (select count(*) from "photos" where content_id = "listings".id AND content_type = 'Listing') > 0  }).
                   includes(:photos).order(%{ random() }).limit(5)

  scope :latest,   order("listings.created_at DESC")
  scope :with_organizations, lambda {|orgs|
    includes(:location => :organizations).
      where <<-SQL, orgs.map(&:id)
        (locations.require_organization_membership = TRUE AND location_organizations.organization_id IN (?))
        OR locations.require_organization_membership = FALSE
      SQL
  }

  include Search
  extend PricingPeriods
  include AvailabilityRule::TargetHelper
  accepts_nested_attributes_for :availability_rules, :allow_destroy => true

  add_pricing_period :daily, MINUTES_IN_DAY
  add_pricing_period :weekly, MINUTES_IN_WEEK
  add_pricing_period :monthly, MINUTES_IN_MONTH

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

  def availability_for(date)
    if availability.open_on?(:date => date)
      # Return the number of free desks
      [self.quantity - desks_booked_on(date), 0].max
    else
      0
    end
  end

  # TODO: Create a database index for the availability.
  # TODO: This implementation is really slow!
  def desks_booked_on(date)
    # Get all of the reservations for the property on the given date
    reservations = Reservation.joins(:periods).where(
        reservation_periods: { listing_id: self.id, date: date }
    )

    # Tally up all of the seats taken across all reservations
    reservations.inject(0) { |sum, r| sum += r.seats.count; sum }
  end


  def price_period
    if free?
      PRICE_PERIODS[:free]
    else
      PRICE_PERIODS[:day]
    end
  end

  def free?
    price.nil? || price == 0.0
  end

  def price
    daily_price
  end

  def price=(price)
    self.daily_price = price
  end

  def price_cents
    daily_period.price_cents
  end

  def price_cents= price
    daily_period.price_cents = price
    daily_period.save if daily_period.persisted?
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

  # FIXME: long method, split me up? Does this/a lot of this belong in Reservation instead?
  def reserve!(email, reserving_user, dates, quantity, assignees = nil)
    # TODO: Use a transaction to ensure atomicity.
    # TODO: Might need to have an elaborate Postgres constraint in order to do this.

    # Check that the reservation is valid
    # FIXME: should be able to do this all in sql
    dates.each do |date|
      available = self.availability_for(date)
      raise DNM::PropertyUnavailableOnDate.new(date, available, quantity) if available < quantity
    end

    # Create the reservation
    reservation = self.reservations.build do |r|
      r.confirmation_email = email
      r.owner = reserving_user
    end

    dates.each do |date|
      reservation.periods << ReservationPeriod.new do |p|
        p.date        = date
        p.listing     = self
        p.reservation = reservation
      end
    end

    unless assignees.blank?

      assignees.each do |assignee|

        reservation.seats << ReservationSeat.new do |s|
          s.reservation = reservation
          s.email       = assignee['email']
          s.name        = assignee['name']
        end

        # Try and look up the e-mail address, in case it refers to a DNM user.
        reservation.seats.last.user ||= User.find_by_email(reservation.seats.last.email)
      end

    else

      (1..quantity).each do |index|
        reservation.seats << ReservationSeat.new do |s|
          s.reservation = reservation
        end
      end

    end

    reservation.save!
    reservation
  end

  def schedule(weeks = 1)
    {}.tap do |hash|
      # Build a hash of all week days and their default availabilities
      weeks.times do |offset|
        today  = Date.today + offset.weeks
        monday = today.weekend? ? today.next_week : today.beginning_of_week
        friday = monday + 4
        week   = monday..friday

        week.inject(hash) {|m,d| m[d] = quantity; m}
      end

      # Fetch count of all reservations for each of those dates
      schedule = reservations.
        where("reservation_periods.date" => hash.keys).
        where(state: [:confirmed, :unconfirmed]).
        includes(:periods, :seats)

      # Subtract the number of reservations from those days to leave
      # how many places are remaining, then return the hash
      schedule.each do |reservation|
        reservation.periods.each do |period|
          if hash[period.date] >= reservation.seats.size
            hash[period.date] -= reservation.seats.size
          else
            hash[period.date] = 0
          end
        end
      end
    end
  end
end
