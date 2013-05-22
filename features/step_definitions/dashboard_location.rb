Given /^(Location|Listing) with my details should be created$/ do |model|
  if model=='Location'
    location = Location.last
    assert_location_data(location)
  else
    listing = Listing.last
    assert_listing_data(listing)
  end
end

Given /^(Location|Listing) should be updated$/ do |model|
  if model=='Location'
    location = Location.last
    assert_location_data(location)
  else
    listing = Listing.last
    assert_listing_data(listing, true)
  end
end

When /^I fill (location|listing) form with valid details$/ do |model|
  if model == 'location'
    fill_location_form
  else 
    fill_listing_form
  end
end

When /^I (disable|enable) (.*) pricing$/ do |action, period|

  page.find("#listing_enable_#{period}").set(action == 'disable' ? false : true)
  if action=='enable'
    page.find("#listing_#{period}_price").set(15.50)
  end

end

When /^I provide new (location|listing) data$/ do |model|
  if model == 'location'
    fill_location_form
  else 
    fill_listing_form
  end
end

When /^I submit the form$/ do
  page.find('#submit-link').click
end

When /^I click edit icon$/ do
  page.find('.edit-link').click
end

When /^I click edit listing icon$/ do
  page.find('.listing .edit-link').click
end

Then /^Listing (.*) pricing should be (disabled|enabled)$/ do |period, state|
  enable_period_checkbox = page.find("#listing_enable_#{period}")
  if state=='enabled'
    assert enable_period_checkbox.checked?
    assert_equal "15.50", page.find("#listing_#{period}_price").value
  else
    assert !enable_period_checkbox.checked?
  end
end

Then /^(Location|Listing) has been deleted$/ do |model|
  if model=='Location'
  assert_nil Location.first
  else
  assert_nil Listing.first
  end
end
