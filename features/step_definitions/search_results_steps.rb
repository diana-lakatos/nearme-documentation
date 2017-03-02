# frozen_string_literal: true
Given /^Auckland listing has prices: (.*), (.*), (.*)$/ do |daily_price, weekly_price, monthly_price|
  listing = Transactable.last
  daily_price.in?(%w(nil 0)) ? listing.action_type.pricing_for('1_day').destroy : listing.action_type.pricing_for('1_day').price = daily_price
  weekly_price.in?(%w(nil 0)) ? listing.action_type.pricing_for('7_day').destroy : listing.action_type.pricing_for('7_day').price = weekly_price
  monthly_price.in?(%w(nil 0)) ? listing.action_type.pricing_for('30_day').destroy : listing.action_type.pricing_for('30_day').price = monthly_price
  unless listing.has_price?
    listing.action_type.pricings.with_deleted.first.restore if listing.action_type.pricings.blank?
    listing.action_type.pricings.with_deleted.first.is_free_booking = true
  end
  listing.action_type.save!
end

When(/^I search for "(.*?)" with (\d+) per page$/) do |q, per_page|
  visit search_path(q: q, per_page: per_page)
end

Given(/^enough listings in Auckland exists to paginate$/) do
  2.times { FactoryGirl.create(:listing_in_auckland) }
  wait_for_elastic_index
end

Then(/^I click to go to next page$/) do
  # Ajax was too laggy for testing
  visit page.all('.next_page').last['href']
end

Then(/^I should ensure "(.*?)" canonical exists$/) do |type|
  selector = "head link[rel='#{type}']"
  page.should have_css selector, visible: false
end
