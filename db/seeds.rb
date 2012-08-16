# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Add dummy data in development
if Rails.env.development? || Rails.env.staging?

  def log(object)
    puts "== #{object.inspect}"
    object
  end

  puts "Creating Listings"
  log(FactoryGirl.create(:listing))

  organizations = [
    log(FactoryGirl.create(:darpa)),
    log(FactoryGirl.create(:nra)),
    log(FactoryGirl.create(:aarp))
  ]
  coffee = FactoryGirl.create(:amenity, :name => "Coffee")
  wifi = FactoryGirl.create(:amenity, :name => "Wifi")
  kitchen = FactoryGirl.create(:amenity, :name => "Kitchen")
  amenities = [
    [coffee],
    [coffee, wifi],
    [coffee, wifi, kitchen]
  ]
  locations = organizations.map do |organization|
    [
      log(FactoryGirl.create(:location_in_auckland, :organizations => [organization], :amenities => amenities.sample)),
      log(FactoryGirl.create(:location_in_cleveland, :organizations => [organization], :amenities => amenities.sample)),
      log(FactoryGirl.create(:location_in_san_francisco, :organizations => [organization], :amenities => amenities.sample))
    ]
  end.flatten

  locations.each do |location|
    log FactoryGirl.create(:listing, :location => location)
  end

end
