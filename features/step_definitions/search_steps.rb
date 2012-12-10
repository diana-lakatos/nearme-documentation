When /^I set the price range to \$(\d+) to \$(\d+)$/ do |min,max|
  set_hidden_field "price_max", max
  set_hidden_field "price_min", min
end

When /^I search for "([^"]*)"$/ do |text|
  update_all_indexes
  fill_in "q", with: text
  if page.current_path =~ /search/
    page.execute_script("$('.query').change()")
  else
    click_link_or_button "Search" unless page.current_path =~ /search/
  end
end

When /^I select that amenity$/ do
  visit search_path
  find('.amenities .collapsed').click
  check model!("amenity").name
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
  Capybara.default_wait_time = 25
  listing = Listing.all.select { |l| l.amenities.include? model("amenity") }.first
  listings_text = page.find('.listing').text
  listings_text.should include listing.name
  Capybara.default_wait_time = 5
end
