When /^I make another search for "([^"]*)"$/ do |query|
  visit root_path
  search_for(query)
end

When /^I search for "([^"]*)"$/ do |text|
  search_for(text)
end

When /^I search with a date range covering the date it is fully booked$/ do
  visit search_path
  search_for(listing.address, { start_date: date_before_listing_is_fully_booked, end_date: date_after_listing_is_fully_booked })
end

When /^I leave and come back$/ do
  visit search_path
end

Then /^I see the listings on a map$/ do
  page.should have_css('div#listings_map')
end

Then /^that listing is not included in the search results$/ do
  page.should_not have_content listing.name
end
