# coding: utf-8
Given /^a( disabled)? listing( with nil prices)? in (.*) exists( with that amenity)?$/ do |disabled, nil_prices, city, amenity|
  listing = create_listing_in(city)
  if nil_prices
    listing.daily_price = nil
    listing.weekly_price = nil
    listing.monthly_price = nil
    listing.free = true if !listing.has_price?
    listing.save!
  end
  if disabled
    listing.enabled = false
    listing.save!
  end
  listing.location.amenities << model!("amenity") if amenity
end

Given /^a listed location( without (amenities))?$/ do |_,_|
  @listing = FactoryGirl.create(:listing)
end

Given /^a listed location with a creator whose email is (.*)?$/ do |email|
  @listing = FactoryGirl.create(:listing)
  @listing.creator.email = email
  @listing.creator.save
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

When /^I view that listing's edit page$/ do
  visit edit_manage_location_path(model!('listing').location)
end

Then /^I (do not )?see a search result for the ([^\$].*) listing$/ do |negative, city|
  listing = instance_variable_get("@listing_in_#{city.downcase.gsub(' ', '_')}")
  if negative
    page.should have_no_selector('article[data-name="' + listing.name + '"]')
  else
    page.should have_selector('article[data-name="' + listing.name + '"]')
  end
end

Then /^I should see the following listings in order:$/ do |table|
  found = all("article.listing h2").map(&:text).uniq
  table.raw.flatten.each_with_index do |listing, index|
    found[index].should include listing
  end
end

