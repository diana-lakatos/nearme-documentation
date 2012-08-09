When /^I create a location for that company$/ do
  visit new_location_path
  @company = model!('company')
  select @company.name, from: 'Company'
  fill_in "Name", with: @location_name = 'Location'
  fill_in "Address", with: '1100 Rock and Roll Boulevard  Cleveland, OH 44114'
  fill_in "Description", with: "There was a house in New Orleans, Bright shining as the sun"
  click_link_or_button "Create Location"
end

Then /^I can select that location when creating listings$/ do
  visit new_listing_path
  select @location_name, from: "Location"
end
