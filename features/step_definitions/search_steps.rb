When /^I set the price range to \$(\d+) to \$(\d+)$/ do |min,max|
  set_hidden_field "price_max", max
  set_hidden_field "price_min", min
end

When /^I search for "([^"]*)"$/ do |query|
  search_for(query)
end

When /^I make another search for "([^"]*)"$/ do |query|
  visit root_path
  search_for(query)
end

When /^I select that amenity$/ do
  find(:css, '.amenities .collapsed').click
  check model!("amenity").name
end

When /^I leave and come back$/ do
  visit search_path
end

Then /^I see the listings on a map$/ do
  page.should have_css('div#listings_map')
end

Then /^the search results have the \$10 listing first$/ do
  prices = page.all('.listing').collect(&:text)
  ten_dollar_listing = Listing.all.find { |l| l.price_cents = 10_00 }
  prices.first.should include ten_dollar_listing.name
end

Then /^the search results have the listing with that amenity first$/ do
  listing = Listing.all.select { |l| l.amenities.include? model("amenity") }.first
  listings_text = page.find('.listing').text
  listings_text.should include listing.name
end
