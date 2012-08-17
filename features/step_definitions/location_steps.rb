When /^I create a location for that company$/ do
  create_location
end

When /^I create a location with that organization$/ do
  create_location do
    check "The Organization"
  end
end

Then /^I can select that location when creating listings$/ do
  visit new_listing_path
  select @location_name, from: "Location"
end

Then /^that location has that organization$/ do
  @location.organizations.should include model!('organization')
end
