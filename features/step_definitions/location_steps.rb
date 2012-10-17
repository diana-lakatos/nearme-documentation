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

When /^I create a location with an alternative currency/ do
  create_location do
    select "EUR - Euro", from: "Currency"
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

Then /^that location has that alternative currency$/ do
  @location.currency.should == "EUR"
end

Then /^that location is private to only members of it's organizations$/ do
  @location.require_organization_membership?.should be_true
end
