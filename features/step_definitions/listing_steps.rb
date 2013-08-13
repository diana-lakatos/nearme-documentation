# coding: utf-8
Given /^a listing( with nil prices)? in (.*) exists( with that amenity)?$/ do |nil_prices, city, amenity|
  listing = create_listing_in(city)
  if nil_prices
    listing.daily_price = nil
    listing.weekly_price = nil
    listing.monthly_price = nil
    listing.free = true if !listing.has_price?
    listing.save!
  end
  listing.location.amenities << model!("amenity") if amenity
end


Given /^there are listings which are unavailable$/ do
  4.times { build_fully_booked_listing }
end

Given /^there are listings which are available$/ do
  4.times { build_listing_which_is_closed_on_weekends }
end

Given /^a listing in (.*) exists with a price of \$(\d+)\.(\d+)( and that amenity)?$/ do |city, dollars, cents, amenity|
  listing = create_listing_in(city)

  listing.price_cents = (dollars.to_i * 100) + cents.to_i
  listing.location.amenities << model!("amenity") if amenity
end

Given /^a listing which is fully booked$/ do
  @listing = build_fully_booked_listing
end

Given /^a listing which is closed on the weekend$/ do
  @listing = build_listing_which_is_closed_on_weekends
end

Given /^a listing in (.*) exists with (\d+) desks? available for the next (\d+) days$/ do |city, desks, num_days|
  build_listing_in_city(city, desks: desks, number_of_days: num_days)
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
    page.should have_no_selector('article[data-name="' + listing.name + '"]')
  else
    page.should have_selector('article[data-name="' + listing.name + '"]')
  end
end

When /^I provide valid listing information$/ do
  create_listing_without_visit(model!("location"), "Valid listing") do
    fill_in "Quantity", with: "2"
    fill_in "Description", with: "Proin adipiscing nunc vehicula lacus varius dignissim."
    fill_in "Price per day", with: "50.00"
    choose "Yes"
    uncheck "Free"
    select "Desk"
  end
end

When /^I don't provide listing type$/ do
  try_to_create_listing(model!("location"), "Invalid listing") do
    select("", :from => "listing_listing_type_id")
  end
end

Then /^this listing should not exist$/ do
  assert_nil Listing.find_by_name("Invalid listing")
end

Then /^this listing should exist$/ do
  listing = Listing.find_by_name("Valid listing")
  assert_equal 2, listing.quantity
  assert_equal "Proin adipiscing nunc vehicula lacus varius dignissim.", listing.description
  assert listing.confirm_reservations
  assert_equal "Desk", listing.listing_type.name
  assert_equal 5000, listing.daily_price.cents
end

Then /^I should see the following listings in order:$/ do |table|
  found = all("article.listing h2").map(&:text).uniq
  table.raw.flatten.each_with_index do |listing, index|
    found[index].should include listing
  end
end

