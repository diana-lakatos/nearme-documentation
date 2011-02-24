class Workplace < ActiveRecord::Base

  attr_accessor :local_geocoding # set this to true in js

  geocoded_by :address

  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :bookings, :dependent => :delete_all
  has_many :photos, :dependent => :delete_all do
    def thumb
      (first || build).thumb
    end
  end
  has_many :feeds, :dependent => :delete_all

  scope :featured, where(%{ (select count(*) from "photos" where workplace_id = "workplaces".id) > 0 }).
                   where(:fake => false).includes(:photos).order(%{ random() }).limit(5)
  scope :latest,   order("workplaces.created_at DESC")

  validates_presence_of :name, :address, :maximum_desks, :latitude, :longitude, :creator_id
  validates_numericality_of :maximum_desks, :only_integer => true, :greater_than => 0
  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_blank => true

  before_validation :fetch_coordinates
  before_save :apply_filter

  delegate :to_s, :to => :name

  attr_protected :description_html, :company_description_html, :creator_id

  define_index do
    indexes :name
    has "RADIANS(latitude)",  :as => :latitude,  :type => :float
    has "RADIANS(longitude)", :as => :longitude, :type => :float
    group_by "latitude", "longitude"
    set_property :delta => true
  end

  def desks_available?(date)
    self.maximum_desks > bookings.on(date).count
  end

  def created_by?(user)
    user && user.admin? || user == creator
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

        week.inject(hash) {|m,d| m[d] = maximum_desks; m}
      end

      # Fetch count of all bookings for each of those dates
      schedule = bookings.select("COUNT(*) as count, date").
        where(:date  => hash.keys).
        where(:state => [:confirmed, :unconfirmed]).
        group(:date)

      # Subtract the number of bookings from those days to leave
      # how many places are remaining, then return the hash
      schedule.each do |booking|
        if hash[booking.date] >= booking.count.to_i
          hash[booking.date] -= booking.count.to_i
        else
          hash[booking.date] = 0
        end
      end
    end
  end

  def self.search_by_location(search, options = {})

    return [] if search[:lat].nil? || search[:lng].nil?

    if (search[:southwest] && search[:southwest][:lat] && search[:southwest][:lng]) && (search[:northeast] && search[:northeast][:lat] && search[:northeast][:lng])
      distance = Geocoder.distance_between(search[:southwest][:lat].to_f, search[:southwest][:lng].to_f,
                                           search[:northeast][:lat].to_f, search[:northeast][:lng].to_f, :units => :km)
      distance = (distance * 1000).to_f
    else
      distance = 30_000.0
    end

    search({ :geo => [ Geocoder.to_radians(search[:lat].to_f), Geocoder.to_radians(search[:lng].to_f) ],
             :with => { "@geodist" => (0.0)..(distance) }, :order => "@geodist ASC, @relevance DESC" }.merge(options))

  end

  private

  def fetch_coordinates
    # If we aren't locally geocoding (cukes and people with JS off)
    if local_geocoding.blank? && address_changed?
      geocoded = Geocoder.search(address).try(:[], 'results').try(:first)
      if geocoded
        self.latitude = geocoded['geometry']['location']['lat']
        self.longitude = geocoded['geometry']['location']['lng']
        self.formatted_address = geocoded['formatted_address']
      end
    end
  end

  def apply_filter
    self.description_html         = redcloth(description)
    self.company_description_html = redcloth(company_description)
  end

  def redcloth(text)
    restrictions = [:sanitize_html, :no_span_caps, :filter_styles, :filter_classes, :filter_ids]
    RedCloth.new(text.to_s, restrictions).to_html
  end

end
