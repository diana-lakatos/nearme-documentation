class Listing < ActiveRecord::Base

  has_many :amenities, through: :listing_amenities
  has_many :listing_amenities

  has_many :organizations, through: :listing_organizations
  has_many :listing_organizations

  has_many :reservations, dependent: :destroy
  has_many :photos,  as: :content, dependent: :destroy
  has_many :ratings, as: :content, dependent: :destroy

  has_one :company, through: :location
  belongs_to :location

  belongs_to :creator, :class_name => "User"

  attr_accessible :location_id, :price_cents, :quantity, :rating_average, :rating_count,
                  :availability_rules, :creator_id, :name, :description

  delegate :name, :description, to: :company, prefix: true
  delegate :address, :latitude, :longitude, to: :location

  monetize :price_cents

  serialize :availability_rules, Hash

  acts_as_paranoid
  # score is to be used by searches. It isn't persisted.
  # Ignore it for the most part.
  attr_accessor :score

  def self.find_by_search_params(params)
    search_hash = {}
    if(params.has_key?("boundingbox"))
      bb = params["boundingbox"]
      search_hash[:locations] = {
        latitude:  bb["start"]["lat"]..bb["end"]["lat"],
        longitude: bb["start"]["lon"]..bb["end"]["lon"]
      }
    end
    listings = includes(:location => :company).where(search_hash)

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

  def self.find_by_query(query)
    includes(:location => :company).search_by_query(query)
  end


  include PgSearch
  pg_search_scope :search_by_query, :against => [:name, :description]

  # TODO: Create a database index for the availability.
  # TODO: This implementation is really slow!
  def availability_for(date)

    # Get all of the reservations for the property on the given date
    reservations = Reservation.joins(:periods).where(
        :reservation_periods => { :listing_id => self.id },
        :reservation_periods => { :date => date }
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
    r = self.ratings.find_or_initialize_by_user_id user.id
    r.rating = rating
    r.save

  end

  def rating_for(user)

    self.ratings.where(user_id: user.id).pluck(:rating).first

  end

end
