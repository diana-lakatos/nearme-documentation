When /^I search for "([^"]*)"$/ do |text|
  search_for(text)
end

When /^I search without setting a date range$/ do
  visit search_path
  search_for(latest_listing.address)
end

When /^I search with a date range covering the date it is fully booked$/ do
  visit search_path
  search_for(listing.address, { start_date: date_before_listing_is_fully_booked, end_date: date_after_listing_is_fully_booked })
end
When /^I performed search for "([^"]*)"$/ do |query|
  visit search_path(:q => query)
end

When /^I make another search for "([^"]*)"$/ do |query|
  visit root_path
  search_for(query)
end

When /^I search with a date range of 2 weeks$/ do
  visit search_path
  search_for(listing.address, { start_date: Date.today, end_date: 2.weeks.from_now })
end

When /^I leave the page and hit back$/ do
  visit root_path
  page.evaluate_script('window.history.back()')
end

When /^I view the results in the (map|list) view$/ do |view|
  click_link view.titlecase
end

Then /^all the listings are included in the search results$/ do
  Listing.all.each do |listing|
    page.should have_content listing.name
  end
end

Then /^I see the listings on a map$/ do
  page.should have_css('#listings_map')
end

Then /^that listing is( not)? included in the search results$/ do |not_included|
  if not_included
    page.should_not have_content listing.name
  else
    binding.pry
    page.should have_content listing.name
  end
end
