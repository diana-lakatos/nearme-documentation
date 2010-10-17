class Workplace < ActiveRecord::Base
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :location
  has_many :bookings
  has_many :photos do
    def thumb
      (first || build).thumb
    end
  end
  has_many :feeds

  # This is horrible. Feel free to fix.
  scope :featured, :include => :photos, :order => %{ "workplaces".created_at desc },
                   :conditions => %{ (select count(*) from "photos" where workplace_id = "workplaces".id) > 0 }, :limit => 5
  scope :latest, order("workplaces.created_at DESC")

  validates_presence_of :name, :address, :maximum_desks, :latitude, :longitude
  validates_numericality_of :maximum_desks, :only_integer => true, :greater_than => 0

  before_validation :fetch_coordinates
  before_save :apply_filter

  delegate :to_s, :to => :name

  define_index do
    indexes :name
    has "RADIANS(latitude)",  :as => :latitude,  :type => :float
    has "RADIANS(longitude)", :as => :longitude, :type => :float
    group_by "latitude", "longitude"
    set_property :delta => true
  end

  def created_by?(user)
    user && user == creator
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def schedule(days = 5)
    today = Date.today

    monday = today.weekend? ? today.next_week : today.beginning_of_week
    week   = monday..(monday + days - 1)
    hash   = week.inject({}) {|m,d| m[d] = maximum_desks; m}

    schedule = bookings.select("COUNT(*) as count, date").
      where(:date  => week).
      where(:state => [:confirmed, :unconfirmed]).
      group(:date)

    hash.tap do |hash|
      schedule.each do |booking|
        if hash[booking.date] >= booking.count.to_i
          hash[booking.date] -= booking.count.to_i
        else
          hash[booking.date] = 0
        end
      end
    end
  end

  def self.search_by_location(query)
    geocoded = Geocoder.search(query).try(:[], 'results').try(:first)
    return [ [], nil ] if geocoded.nil?

    location = { :name => geocoded['formatted_address'],
                 :lat => geocoded['geometry']['location']['lat'],
                 :lng => geocoded['geometry']['location']['lng'] }

    [ search(:geo => [ Geocoder.to_radians(location[:lat]), Geocoder.to_radians(location[:lng]) ],
             :with => { "@geodist" => (0.0)..(30_000.0) }, :order => "@geodist ASC, @relevance DESC") , location ]
  end

  private

    def fetch_coordinates
      geocoded = Geocoder.search(address).try(:[], 'results').try(:first)
      if geocoded
        self.latitude  = geocoded['geometry']['location']['lat']
        self.longitude = geocoded['geometry']['location']['lng']
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
