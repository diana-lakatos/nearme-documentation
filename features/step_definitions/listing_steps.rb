# coding: utf-8
Given /^a( disabled)?( indexed)? listing( with nil prices)? in (.*) exists( with that amenity)?$/ do |disabled, indexed, nil_prices, city, amenity|
  listing = create_listing_in(city)
  if nil_prices
    listing.action_type.pricings[1..-1].delete_all
    listing.action_type.pricings.first.is_free_booking = true
    listing.save!
  end
  if disabled
    listing.enabled = false
    listing.save!
  end
  listing.location.amenities << model!("amenity") if amenity
  Transactable.__elasticsearch__.refresh_index! if indexed
end

Given /^a listed location( without (amenities))?$/ do |_,_|
  @listing = FactoryGirl.create(:transactable, :with_time_based_booking)
end

Given /^a listed location with a creator whose email is (.*)?$/ do |email|
  @listing = FactoryGirl.create(:transactable, :with_time_based_booking)
  @listing.creator.email = email
  @listing.creator.save
end

Given /^a listed location in San Francisco that does( not)? require confirmation$/ do |confirmation|
  @listing = FactoryGirl.create(:listing_in_san_francisco, confirm_reservations: !confirmation)
end

Given /^(.*) does( not)? require confirmation for his listing$/ do |person, with_confirmation|
  @listing = FactoryGirl.create(:transactable)
  @listing.confirm_reservations = !with_confirmation
  @listing.save
  @listing.company.update_attribute(:creator_id, User.find_by_name(person).id)
  @listing.reload
end

When /^I view that transactable's edit page$/ do
  visit edit_dashboard_company_location_path(model!('transactable').location)
end

Then /^I (do not )?see a search result for the ([^\$].*) listing$/ do |negative, city|
  listing = instance_variable_get("@listing_in_#{city.downcase.gsub(' ', '_')}")
  if negative
    page.should have_no_selector('article[data-id="' + listing.id.to_s + '"]')
  else
    page.should have_selector('article[data-id="' + listing.id.to_s + '"]')
  end
end

Then /^I should see the following listings in order:$/ do |table|
  found = all("article.listing h2").map(&:text).uniq
  table.raw.flatten.each_with_index do |listing, index|
    found[index].should include listing
  end
end

