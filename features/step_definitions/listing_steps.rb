# coding: utf-8
Given /^a listing in (.*) exists( with that amenity)?$/ do |city, amenity|
  listing = create_listing_in(city)
  listing.location.amenities << model!("amenity") if amenity
end

Given /^a listing in (.*) exists with a price of \$(\d+)\.(\d+)( and that amenity)?$/ do |city, dollars, cents, amenity|
  listing = create_listing_in(city)

  listing.price_cents = (dollars.to_i * 100) + cents.to_i
  listing.location.amenities << model!("amenity") if amenity
end

Given /^a listing in (.*) exists with (\d+) desks? available for the next (\d+) days$/ do |city, desks, num_days|
  listing = create_listing_in(city)

  listing.update_column(:quantity, desks)

  listing.availability_rules.clear
  wday = Time.now.wday
  (wday .. (wday+num_days.to_i)).each do |day|
    listing.availability_rules.create!(:day => day % 7, :open_hour => 8, :close_hour => 18)
  end

  (Date.today...num_days.to_i.days.from_now.to_date).all? { |d| listing.availability_for(d) >= desks.to_i }.should == true
end

Given /^a listed location( without (amenities))?$/ do |_,_|
  @listing = FactoryGirl.create(:listing)
end

Given /^a listed location with a creator whose email is (.*)?$/ do |email|
  @listing = FactoryGirl.create(:listing)
  @listing.creator.email = email
  @listing.creator.save
end

Given /^a listed location with an amenity/ do
  store_model('listing', 'listing', FactoryGirl.create(:listing_with_amenity))
  store_model('location', 'location', model!('listing').location)
  store_model('amenity', 'amenity', model!('location').amenities.first)
end

Given /^a listed location in San Francisco that does( not)? require confirmation$/ do |confirmation|
  @listing = FactoryGirl.create(:listing_in_san_francisco, confirm_reservations: !confirmation)
end

Given /^(.*) does( not)? require confirmation for his listing$/ do |person, with_confirmation|
  @listing = FactoryGirl.create(:listing)
  @listing.confirm_reservations = !with_confirmation
  @listing.save
  @listing.creator = User.find_by_name(person)
end

When /^I create a listing for that location with availability rules$/ do
  create_listing(model!("location")) do
    choose AvailabilityRule.templates.first.full_name
  end
end

When /^I visit that listing$/ do
  visit listing_path(model!('listing'))
end

When /^I view that listing$/ do
  visit listing_path(model!('listing'))
end

When /^I view that listing's edit page$/ do
  visit edit_manage_location_path(model!('listing').location)
end

Then /^I (do not )?see that listing listed$/ do |negative|
  if negative
    page.should have_no_content model!("listing").name
  else
    page.should have_content model!("listing").name
  end
end

Then /^I (do not )?see a search result for the ([^\$].*) listing$/ do |negative, city|
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
end

Then /^the listing (daily |weekly |monthly )?price is shown as (.*)$/ do |period, amount|
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

Then /^I should see the following listings in order:$/ do |table|
  found = all("article.listing h2")
  table.raw.flatten.each_with_index do |listing, index|
    found[index].text.should include listing
  end
end

Then /^I should see the creators gravatar/ do
  page.should have_css(".host .avatar")
end

