Given /^a listed location with an organization$/ do
  @listing = FactoryGirl.create(:listing_with_organization)
end

Given /^a listed location( without (amenities|organizations))?$/ do |_,_|
  @listing = FactoryGirl.create(:listing)
end

Given /^a listed location with an amenity with the id of 1$/ do
  FactoryGirl.create(:listing_with_amenity)
end

Given /^a listed location with a creator whose email is (.*)?$/ do |email|
  @listing = FactoryGirl.create(:listing, creator: FactoryGirl.create(:user, email: email))
end

Given /^a location exists with organizations$/ do
  @location = FactoryGirl.create(:location, organizations: [FactoryGirl.create(:aarp)])
end
When /^I create a location for that company$/ do
  create_location
end

When /^I create a location with that organization$/ do
  create_location do
    check model("organization").name
  end
end

When /^I create a private location with that organization$/ do
  create_location do
    check model("organization").name
    check "location_require_organization_membership"
  end
end

When /^I create a location with that amenity$/ do
  create_location do
    check model!('amenity').name
  end
end

Then /^I can select that location when creating listings$/ do
  visit new_listing_path
  select @location_name, from: "Location"
end

Then /^that location has that (\w+)$/ do |resource|
  @location.send(resource.pluralize).should include model!(resource)
end

Then /^that location is private to only members of it's organizations$/ do
  @location.require_organization_membership?.should be_true
end
