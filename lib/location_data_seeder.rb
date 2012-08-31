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
    create_organizations
    seed_amenities
    seed_organizations
  end

  private

    def create_amenities
      @amenities = SEED_AMENITY_NAMES.map do |n|
        Amenity.find_or_create_by_name(n)
      end
    end

    def create_organizations
      @organizations = SEED_ORGANIZATIONS.map do |n|
        o = Organization.find_or_initialize_by_name(n)

        if (rand * 10) > 5
          o.logo = File.open(Rails.root.join("lib", "seed_images", LOGO_IMAGES.sample))
        end
        o.save
        o
      end
    end

    def seed_amenities
      @locations.each do |l|
        num_amenities = (rand * (@amenities.size / 2)) + 1
        l.amenities   = @amenities.sample(num_amenities)
      end
    end

    def seed_organizations
      @locations.each do |l|
        num_orgs        = (rand * (@organizations.size / 2)) + 1
        l.organizations = @organizations.sample(num_orgs)
      end
    end

end