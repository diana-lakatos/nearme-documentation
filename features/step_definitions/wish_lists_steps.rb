And(/^wish lists are enabled for the instance$/) do
  PlatformContext.current.instance.update_attribute :wish_lists_enabled, true
end

And(/^wish lists are disabled for the instance$/) do
  PlatformContext.current.instance.update_attribute :wish_lists_enabled, false
end

When(/^I click to Add to Favorites$/) do
  click_on 'Add to Favorites'
end

When(/^I click to Remove from Favorites$/) do
  click_on 'Remove from Favorites'
end

Given(/^I visit dashboard wish list page$/) do
  visit '/dashboard/favorites'
end

When(/^I click to Delete$/) do
  click_on 'Delete'
end

And(/^I have one favorite item$/) do
  Location.last.wish_list_items.create wish_list_id: User.last.default_wish_list.id
end

Then(/^I visit product page$/) do
  visit product_path(Spree::Product.last)
end
