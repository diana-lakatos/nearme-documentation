Given /^I search for "([^"]*)"$/ do |text|
  update_all_indexes
  visit '/'
  fill_in "q", with: text
  click_link_or_button "Search"
end

Then /^I see the listings on a map$/ do
  page.should have_css('div#listings_map')
end

