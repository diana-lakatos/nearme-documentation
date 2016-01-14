Given /^Auckland listing has prices: (.*), (.*), (.*)$/ do |daily_price, weekly_price, monthly_price|
  listing = Transactable.last
  listing.daily_price = (daily_price=='nil' ? nil : daily_price)
  listing.weekly_price = (weekly_price=='nil' ? nil : weekly_price)
  listing.monthly_price = (monthly_price=='nil' ? nil : monthly_price)
  listing.action_free_booking = true if !listing.has_price?
  listing.save!
end

When(/^I search for "(.*?)" with (\d+) per page$/) do |q, per_page|
  visit search_path(q: q, per_page: per_page)
end

Given(/^enough listings in Auckland exists to paginate$/) do
  2.times { FactoryGirl.create(:listing_in_auckland) }
end

Then(/^I click to go to next page$/) do
  # Ajax was too laggy for testing
  visit page.all(".next_page").last['href']
end

Then(/^I should ensure "(.*?)" canonical exists$/) do |type|
  selector = "head link[rel='#{type}']"
  page.should have_css selector, :visible => false
end
