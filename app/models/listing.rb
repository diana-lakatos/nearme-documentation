class Listing < ActiveRecord::Base

  has_many :feeds, dependent: :delete_all
  has_many :reservations, dependent: :destroy
  has_many :reservations, dependent: :delete_all
  has_many :photos,  as: :content, dependent: :destroy do
    def thumb
      (first || build).thumb
    end
  end
  has_many :ratings, as: :content, dependent: :destroy

  has_many :inquiries

  has_one :company, through: :location
  belongs_to :location

  belongs_to :creator, class_name: "User"

  attr_accessible :confirm_reservations, :location_id, :price_cents, :quantity, :rating_average, :rating_count,
                  :availability_rules, :creator_id, :name, :description, :price

  delegate :name, :description, to: :company, prefix: true
  delegate :url, to: :company
  delegate :address, :amenities, :formatted_address, :local_geocoding, :organizations, :latitude,
    :longitude, to: :location

  delegate :to_s, to: :name

  monetize :price_cents

  serialize :availability_rules, Hash

  acts_as_paranoid
  # score is to be used by searches. It isn't persisted.
  # Ignore it for the most part.
  attr_accessor :score

  scope :featured, where(%{ (select count(*) from "photos" where content_id = "listings".id AND content_type = 'Listing') > 0  }).
                   includes(:photos).order(%{ random() }).limit(5)

  scope :latest,   order("listings.created_at DESC")

  # thinking sphinx searching
  define_index do
    join location

    indexes :name, :description

    has "radians(#{Location.table_name}.latitude)",  as: :latitude,  type: :float
    has "radians(#{Location.table_name}.longitude)", as: :longitude, type: :float

    group_by :latitude, :longitude
  end

  def self.find_by_search_params(params)
    search_hash = {}
    if(params.has_key?("boundingbox"))
      bb = params["boundingbox"]
      search_hash[:locations] = {
        latitude:  bb["start"]["lat"]..bb["end"]["lat"],
        longitude: bb["start"]["lon"]..bb["end"]["lon"]
      }
    end
    listings = includes(location: :company).where(search_hash)

    if(params.has_key?("amenities"))
      listings.select! do |l|
        l.amenities.any? { |a| params["amenities"].include? a.id }
      end
    end

    if(params["organizations"])
      listings.select! do |l|
        l.organizations.any? { |a| params["organizations"].include?(a.id) }
      end
    end

    listings
  end

  def self.search_by_location(search)
    return self if search[:lat].nil? || search[:lng].nil?

    distance = if (search[:southwest] && search[:southwest][:lat] && search[:southwest][:lng]) &&
                  (search[:northeast] && search[:northeast][:lat] && search[:northeast][:lng])
      Geocoder::Calculations.distance_between([ search[:southwest][:lat].to_f, search[:southwest][:lng].to_f ],
                                              [ search[:northeast][:lat].to_f, search[:northeast][:lng].to_f ], units: :km)
    else
      30
    end
    Location.near([ search[:lat].to_f, search[:lng].to_f ], distance, order: "distance", units: :km)
  end

  def self.find_by_query(query)
    includes(location: :company).search_by_query(query)
  end

  include PgSearch
  pg_search_scope :search_by_query, against: [:name, :description]

  # TODO: Create a database index for the availability.
  # TODO: This implementation is really slow!
  def availability_for(date)

    # Get all of the reservations for the property on the given date
    reservations = Reservation.joins(:periods).where(
        reservation_periods: { listing_id: self.id },
        reservation_periods: { date: date }
    )

    # Tally up all of the seats taken across all reservations
    desks_taken = 0
    reservations.each { |r| desks_taken += r.seats.count }

    # Return the number of free desks
    [self.quantity - desks_taken, 0].max

  end


  def price_hash

    {
      amount:        price.to_f,
      label:         price.format,
      currency_code: price.currency.iso_code
    }

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