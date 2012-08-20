When /^I create a location for that company$/ do
  create_location
end

When /^I create a location with that organization$/ do
  create_location do
    check "The Organization"
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
