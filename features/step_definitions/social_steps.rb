# frozen_string_literal: true
Given /^the (.*) OAuth request is successful$/ do |social|
  mock_successful_authentication_with_provider(social)
end

Given /^the (.*) OAuth request is unsuccessful$/ do |social|
  mock_unsuccessful_authentication_with_provider(social)
end

Given /^Existing user with (.*) email$/ do |social|
  pre_existing_user(email: "#{social.downcase}@example.com")
end

When /I sign up with (.*)$/ do |social|
  stub_authentication_creation_callbacks if social == 'Facebook'
  sign_up_with_provider(social)
end

When /I sign in with Twitter$/ do
  sign_in_with_provider('Twitter')
end

When /I sign up as (.*) in the modal/ do |_model|
  work_in_modal do
    within '.sign-up-modal' do
      fill_in_user_sign_up_details
      click_on 'Sign up'
    end
  end
  page.should_not have_css('[data-modal-class="sign-up-modal"]')
end

Given /I signed up with (.*) without password$/ do |social|
  mock_successful_authentication_with_provider(social)
  sign_up_with_provider(social)
end

Given /I signed up with (.*) with password$/ do |social|
  sign_up_manually(email: "#{social.downcase}@example.com")
  mock_successful_authentication_with_provider(social)
  toggle_connection_with(social)
end

When /I connect to (.*)$/ do |social|
  stub_authentication_creation_callbacks
  mock_successful_authentication_with_provider(social)
  toggle_connection_with(social)
end

When /I want connect to (.*) that belongs to other user$/ do |social|
  create_user_for_provider(social)
  mock_successful_authentication_with_provider(social)
  toggle_connection_with(social)
end

When /I disconnect (.*)/ do |social|
  toggle_connection_with(social)
end

When /I want to disconnect/ do
  visit edit_user_registration_path
end

Then /I cannot disconnect (.*)$/ do |social|
  toggle_connection_with(social)
  assert_not_nil Authentication.find_by(provider: social.downcase)
end

When /I try to sign up with (.*)$/ do |social|
  try_to_sign_up_with_provider(social)
end

When /I type in my password in edit page/ do
  update_current_user_information(password: 'my_password', country_name: 'United States')
end

Then /I should have password/ do
  assert User.first.has_password?
end

When /I manually sign up with valid credentials$/ do
  sign_up_manually(name: 'I am User')
end

When /I navigate away via Log In link and sign in$/ do
  click_link 'Log In'
  work_in_modal do
    fill_credentials
    click_button 'Log In'
  end
end

When /I sign in with valid credentials/ do
  login_manually
end

When /I sign in with invalid credentials/ do
  click_link 'Log In'
  work_in_modal do
    fill_credentials('invalid@example.com')
    click_button 'Log In'
  end
end

When /I fill in invalid credentials and click (.*) button$/ do |button|
  fill_credentials('invalid@example.com')
  click_button button
end

When /I fill in valid credentials and click (.*) button$/ do |button|
  fill_credentials
  click_button button
end

Then /an account should be created for that (.*) user$/ do |social|
  social = social.downcase
  user = Authentication.find_by(provider: social).user
  assert_equal "#{social}@example.com", user.email
  assert_equal 1, user.authentications.count
  assert_equal social, user.authentications.first.provider
end

Then /account of valid user should be connected with (.*)$/ do |social|
  social = social.downcase
  user = Authentication.find_by(provider: social).user
  assert_equal 'valid@example.com', user.email
  assert_equal 1, user.authentications.count
  assert_equal social, user.authentications.first.provider
end

Then /there should be no (.*) account$/ do |social|
  assert_nil Authentication.find_by(provider: social.downcase)
end

Then /I am correctly signed in/ do
  user = User.find_by(email: 'valid@example.com')
  assert_equal 'I am User', user.name
end

Then /^I do (not )?have avatar$/ do |without_avatar|
  user = User.last
  if without_avatar
    assert !user.avatar.file.present?
  else
    assert user.avatar.file.present?
  end
end

Then /^I should not be relogged as other user$/ do
  current_path = URI.parse(current_url).path
  assert_equal social_accounts_path, current_path
end

Given /^the (.*) OAuth request with email is successful$/ do |social|
  mock_successful_authentication_with_provider(social, info: { email: "#{social.downcase}@example.com" })
end

Given /There is no user with my email/ do
end
