# frozen_string_literal: true
When(/^I visit 'refer\-contact' page$/) do
  visit '/refer-contact'
end

When(/^I fill in all fields and submit form$/) do
  Customization.destroy_all
  fill_in 'Enquirer name', with: 'John Doe'
  fill_in 'Enquirer email', with: 'john@gmail.com'
  click_button 'Save'
end

Then(/^I should be redirected to home_page$/) do
  assert_equal '/', current_path
end

Then(/^I should get an email$/) do
  assert_equal 1, ActionMailer::Base.deliveries.size
  @email = ActionMailer::Base.deliveries.first
  assert_equal ['john@gmail.com'], @email.to
end

Then(/^customization is stored in database$/) do
  assert_equal 1, Customization.count
end
