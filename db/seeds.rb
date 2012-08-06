# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Add dummy data in development
if Rails.env.development? || Rails.env.staging?

  def log(object)
    puts "== #{object.inspect}"
    object
  end

  puts "Creating Listings"
  log(FactoryGirl.create(:listing_with_amenity))
  log(FactoryGirl.create(:listing_with_organization))
  log(FactoryGirl.create(:listing))
end
