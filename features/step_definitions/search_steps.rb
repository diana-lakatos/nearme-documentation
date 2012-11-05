When /^I set the price range to \$(\d+) to \$(\d+)$/ do |min,max|

  set_hidden_field "price_max", max
  set_hidden_field "price_min", min
end

When /^I search for "([^"]*)"$/ do |text|
  update_all_indexes
  fill_in "q", with: text
  click_link_or_button "Search"
end

Then /^I see the listings on a map$/ do
  page.should have_css('div#listings_map')
end

Then /^the search results have the lowest price first$/ do

  prices = page.all('.listing').collect(&:text).collect { |l| l.match(/\$(\d+)/)[1].to_i }
  prices.each_cons(2) { |first,second| raise "Listing with price #{first} is before listing with price #{second}" unless first < second }

end

