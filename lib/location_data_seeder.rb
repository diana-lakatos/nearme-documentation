class LocationDataSeeder

  SEED_AMENITY_NAMES = [
    "Wi-Fi",
    "Bouncy Ball Pit",
    "Pool Table",
    "Free Beer",
    "Good Coffee",
    "Couches",
    "Nap Area",
    "In-house Masseuse"
  ]

  SEED_ORGANIZATIONS = [
    "FBI",
    "NSA",
    "NASA",
    "DIA",
    "DOA",
    "CIA",
    "POTUS"
  ]

  LOGO_IMAGES = [
    "cat1.jpg", "cat2.jpg", "pug1.jpg", "pug2.jpg", "pug3.jpg"
  ]

  attr_accessor :seed

  def self.seed(locations)
    new(locations).seed
  end

  def initialize(locations)
    @locations = locations
  end

  def seed
    create_amenities
    seed_amenities
  end

  private

    def create_amenities
      @amenities = SEED_AMENITY_NAMES.map do |n|
        Amenity.find_or_create_by_name(n)
      end
    end

    def seed_amenities
      @locations.each do |l|
        num_amenities = (rand * (@amenities.size / 2)) + 1
        l.amenities   = @amenities.sample(num_amenities)
      end
    end
end
