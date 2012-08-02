class Workplace < ActiveRecord::Base

  attr_accessor :local_geocoding # set this to true in js

  geocoded_by :address

  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :bookings, :dependent => :delete_all
  has_many :photos, :as => :content, :dependent => :delete_all do
    def thumb
      (first || build).thumb
    end
  end
  has_many :feeds, :dependent => :delete_all

  scope :featured, where(%{ (select count(*) from "photos" where content_id = "workplaces".id AND content_type = 'Workplace') > 0  }).
                   where(:fake => false).includes(:photos).order(%{ random() }).limit(5)
  scope :latest,   order("workplaces.created_at DESC")

  validates_presence_of :name, :address, :maximum_desks, :latitude, :longitude, :creator_id
  validates_numericality_of :maximum_desks, :only_integer => true, :greater_than => 0
  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_blank => true

  before_validation :fetch_coordinates
  before_save :apply_filter

  delegate :to_s, :to => :name

  attr_protected :description_html, :company_description_html, :creator_id

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

  def self.search_by_location(search)
    return self if search[:lat].nil? || search[:lng].nil?

    distance = if (search[:southwest] && search[:southwest][:lat] && search[:southwest][:lng]) &&
                  (search[:northeast] && search[:northeast][:lat] && search[:northeast][:lng])
      Geocoder::Calculations.distance_between([ search[:southwest][:lat].to_f, search[:southwest][:lng].to_f ],
                                              [ search[:northeast][:lat].to_f, search[:northeast][:lng].to_f ], :units => :km)
    else
      30
    end

    near([ search[:lat].to_f, search[:lng].to_f ], distance, :order => "distance", :units => :km)
  end

  private

    def fetch_coordinates
      # If we aren't locally geocoding (cukes and people with JS off)
      if address_changed? && !(latitude_changed? || longitude_changed?)
        geocoded = Geocoder.search(address).try(:first)
        if geocoded
          self.latitude = geocoded.coordinates[0]
          self.longitude = geocoded.coordinates[1]
          self.formatted_address = geocoded.formatted_address
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
