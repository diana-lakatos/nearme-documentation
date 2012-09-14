Given /^a listing in (.*) exists$/ do |city|
  create_listing_in(city)
end

Given /^a listing in (.*) exists with a price of \$(\d+)\.(\d+)( and Wi\-Fi)?$/ do |city, dollars, cents, wifi|
  listing = create_listing_in(city)

  listing.update_column(:price_cents, (dollars.to_i * 100) + cents.to_i)
  listing.location.amenities << @wifi if wifi
end

Given /^a listing in (.*) exists which is (NOT )?a member of that organization$/ do |city, not_member|
  listing = create_listing_in(city)

  unless not_member.present?
    listing.location.organizations << model!("organization")
    listing.location.organizations.should include model!("organization")
  else
    listing.location.organizations.should_not include model!("organization")
  end
end

Given /^a listing in (.*) exists with (\d+) desks? available for the next (\d+) days$/ do |city, desks, num_days|
  listing = create_listing_in(city)

  listing.update_column(:quantity, desks)
  (Date.today...num_days.to_i.days.from_now.to_date).all? { |d| listing.availability_for(d) >= desks.to_i }.should == true
end

Given /^a listing(?: with name "([^"]+)")? exists for a location with a private organization?$/ do |name|
  location = FactoryGirl.create(:private_location)

  listing_attrs = { location: location }
  listing_attrs.merge!(name: name) if name.present?

  store_model('listing', 'listing for private location', FactoryGirl.create(:listing, listing_attrs))
  store_model('location', 'organization', location)
  store_model('organization', 'organization', location.organizations.first)
end

Given /^a listed location with an organization$/ do
  @listing = FactoryGirl.create(:listing_with_organization)
end

Given /^a listed location( without (amenities|organizations))?$/ do |_,_|
  @listing = FactoryGirl.create(:listing)
end

Given /^a listed location with a creator whose email is (.*)?$/ do |email|
  @listing = FactoryGirl.create(:listing, creator: FactoryGirl.create(:user, email: email))
end

Given /^a listed location with an amenity/ do
  store_model('listing', 'listing', FactoryGirl.create(:listing_with_amenity))
  store_model('location', 'location', model!('listing').location)
  store_model('amenity', 'amenity', model!('location').amenities.first)
end

Given /^a listed location in San Francisco that does( not)? require confirmation$/ do |confirmation|
  @listing = FactoryGirl.create(:listing_in_san_francisco, confirm_reservations: !confirmation)
end

When /^I create a listing for that location with a price of \$(\d+)\.(\d+)$/ do |dollars, cents|
  create_listing(model!("location")) do
    fill_in "Price", with: "#{dollars}.#{cents}"
  end
end

When /^I create a listing for that location with availability rules$/ do
  create_listing(model!("location")) do
    fill_in "Availability rules", with: "I'm always available"
  end
end

When /^I create a listing for an organization$/ do
  create_listing(model!("location")) do
    check Organization.first.name
  end
end

When /^I visit that listing$/ do
  visit listing_path(model!('listing'))
end

When /^I view that listing$/ do
  visit listing_path(model!('listing'))
end

Then /^I (do not )?see that listing listed$/ do |negative|
  if negative
    page.should have_no_content model!("listing").name
  else
    page.should have_content model!("listing").name
  end
end

Then /^I (do not )?see a search result for the (.*) listing$/ do |negative, city|
  listing = instance_variable_get("@listing_in_#{city.downcase.gsub(' ', '_')}")
  if negative
    page.should have_no_content(listing.name)
  else
    page.should have_content(listing.name)
  end
end

Then /^I see the listing details$/ do
  page.should have_content(listing.address)
  page.should have_content(listing.name)
  page.should have_content(listing.description.strip)
  page.should have_content(listing.url)
end

Then /^the listing price is shown as (.*)$/ do |amount|
  visit listing_path(listing)
  page.should have_content(amount)
  visit listings_path
  page.should have_content(amount)
end

Then /^the listing shows the availability rules$/ do
  visit listing_path(listing)
  page.should have_content("I'm always available")
end

Then /^I cannot view that listing$/ do
  page.should have_content "Sorry, you don't have permission to view that"
  current_path.should == listings_path
end
