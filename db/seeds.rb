# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Add dummy data in development
if Rails.env.development? || Rails.env.staging?

  def log(object)
    puts "== #{object.inspect}"
    object
  end

  if(Location.count==0)

    coffee = FactoryGirl.create(:amenity, :name => "Coffee")
    wifi = FactoryGirl.create(:amenity, :name => "Wifi")
    kitchen = FactoryGirl.create(:amenity, :name => "Kitchen")
    amenities = [
      [coffee],
      [coffee, wifi],
      [coffee, wifi, kitchen]
    ]

    locations = [
      log(FactoryGirl.create(:location_in_auckland, :amenities => amenities.sample)),
      log(FactoryGirl.create(:location_in_cleveland, :amenities => amenities.sample)),
      log(FactoryGirl.create(:location_in_san_francisco, :amenities => amenities.sample))
    ]

    locations.each do |location|
      listing =  FactoryGirl.create(:listing, :location => location)
    end

  end

end

["Accounting", "Atvertising", "Apparel", "Automotive",
  "Banking", "Broadcasting", "Brokerage", "Biotechnology",
  "Computer", "Consulting", "Education", "Electronics",
  "Energy", "Entertainment", "Executive Search", "Financial Services",
  "Farming", "Food & Beverage", "Gaming", "Health Professional",
  "Insurance", "Internet", "Investment Banking", "Legal",
  "Lodging", "Manufacturing", "Medical" , "Movies",
  "Music", "Pharmaceutical", "Private Equity", "Publishing",
  "Real Estate", "Retail", "Service", "Software",
  "Sports" , "Technology", "Telecommunications", "Tourism",
  "Transportation", "Venture Capital", "Wholesale"].each do |name|
  log(Industry.create(:name => name)) unless Industry.find_by_name(name)
  end
