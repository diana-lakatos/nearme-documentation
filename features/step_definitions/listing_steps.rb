Given /^a listing in (.*) exists$/ do |city|
  instance_variable_set "@listing_in_#{city.downcase.gsub(' ', '_')}",
  FactoryGirl.create("listing_in_#{city.downcase.gsub(' ', '_')}")
end

Given /^a listing exists for a location with a private organization$/ do
  location = FactoryGirl.create(:private_location)
  store_model('listing', 'listing for private location', FactoryGirl.create(:listing, location: location))
  store_model('location', 'organization', location)
  store_model('organization', 'organization', location.organizations.first)
end

Given /^a listed location with an organization with the id of 1$/ do
  FactoryGirl.create(:listing_with_organization)
end

Given /^a listed location( without (amenities|organizations))?$/ do |_,_|
  @listing = FactoryGirl.create(:listing)
end

Given /^a listed location with an amenity/ do
  store_model('listing', 'listing', FactoryGirl.create(:listing_with_amenity))
  store_model('location', 'location', model!('listing').location)
  store_model('amenity', 'amenity', model!('location').amenities.first)
end

Given /^a listed location with an amenity with the id of 1$/ do
  FactoryGirl.create(:listing_with_amenity)
end

Given /^a listed location with a creator whose email is (.*)?$/ do |email|
  @listing = FactoryGirl.create(:listing, creator: FactoryGirl.create(:user, email: email))
end


When /^I create a listing for that location with a price of \$(\d+)\.(\d+)$/ do |dollars, cents|
  create_listing(model!("location")) do
    fill_in "Price", with: "#{dollars}.#{cents}"
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

Then /^I cannot view that listing$/ do
  page.should have_content "Sorry, you don't have permission to view that"
  current_path.should == listings_path
end
