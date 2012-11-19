When /^I set the price range to \$(\d+) to \$(\d+)$/ do |min,max|
  set_hidden_field "price_max", max
  set_hidden_field "price_min", min
end

When /^I select that amenity$/ do
  visit '/'
  page.execute_script("$('#amenities_#{model!("amenity").id}').attr('checked',true)")
end

When /^I search for "([^"]*)"$/ do |text|
  update_all_indexes
  fill_in "q", with: text
  click_link_or_button "Search"
end

Then /^I see the listings on a map$/ do
  page.should have_css('div#listings_map')
end

Then /^the search results have the \$10 listing first$/ do
  prices = page.all('.listing').collect(&:text)
  prices.first.should =~ /\$10/
end

Then /^the search results have the listing with that amenity first$/ do
  listing = Listing.all.select { |l| l.amenities.include? model("amenity") }.first
  listings_text = page.all('.listing').collect(&:text)
  listings_text.first.should include listing.name
end

