Given /^Location with my details should be created$/ do
  location = Location.last
  assert_location_data(location)
end

Given /^Location should be updated$/ do
  location = Location.last
  assert_location_data(location)
end

When /^I fill location form with valid details$/ do
  fill_location_form
end

When /^I provide new location data$/ do
  fill_location_form
end

When /^I submit the form$/ do
  click_button 'Save'
end

When /^I click edit icon$/ do
  page.find('.edit-link').click
end

Then /^Location has been deleted$/ do
  assert_nil Location.first
end
