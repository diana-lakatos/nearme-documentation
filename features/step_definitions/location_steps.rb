Then /^I should see other listings near "(.*)"$/ do |address|
  page.should have_content("Displaying other listings near #{address}")
  assert_equal search_path(:q => address), "#{URI.parse(current_url).path}?#{URI.parse(current_url).query}"
end

Then(/^I should be redirected to the first listing page$/) do
  current_path = URI.parse(current_url).path
  location = Location.last
  listing = location.listings.active.first
  assert_equal location_listing_path(location, listing), current_path
end
