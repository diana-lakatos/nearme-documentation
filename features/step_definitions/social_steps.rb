Before do
  disable_remote_http
end

Given /^the (.*) OAuth request is successful$/ do |social|
  mock_successful_authentication_with_provider(social)
end

Given /^the (.*) OAuth request is unsuccessful$/ do |social|
  mock_unsuccessful_authentication_with_provider(social)
end

Given /^Existing user with (.*) email$/ do |social|
  pre_existing_user({:email => "#{social.downcase}@example.com"})
end

When /I sign up with (.*)$/ do |social|
  sign_up_with_provider(social)
end

When /I sign up as (.*) in the modal/ do |model|
  work_in_modal do
    within '.sign-up-modal' do
      fill_in_user_sign_up_details()
      click_on 'Sign up'
    end
  end
end

Given /I signed up with (.*) without password$/ do |social|
  mock_successful_authentication_with_provider(social)
  sign_up_with_provider(social)
end

Given /I signed up with (.*) with password$/ do |social|
  sign_up_manually({:email => "#{social.downcase}@example.com"})
  mock_successful_authentication_with_provider(social)
  toggle_connection_with(social)
end

When /I connect to (.*)$/ do |social|
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
  assert_not_nil Authentication.find_by_provider(social.downcase)
end

When /I try to sign up with (.*)$/ do |social|
  try_to_sign_up_with_provider(social)
end

When /I type in my password in edit page/ do
  update_current_user_information({:password => 'my_password', :country_name => 'United States'})
end

Then /I should have password/ do
  assert User.first.has_password?
end

When /I manually sign up with valid credentials$/ do 
  sign_up_manually({:name => 'I am user'})
end

When /I navigate away via Log In link and sign in$/ do 
  click_link 'Log In'
  login_manually
end

When /I sign in with valid credentials/ do 
  login_manually
end

When /I sign in with invalid credentials/ do 
  click_link 'Log In'
  login_manually('invalid@example.com')
end

Given /There is no user with my email/ do
end

Then /an account should be created for that (.*) user$/ do |social|
  social = social.downcase
  user = Authentication.find_by_provider(social).user
  assert_equal "#{social}@example.com", user.email
  assert_equal 1, user.authentications.count
  assert_equal social, user.authentications.first.provider
end

Then /account of valid user should be connected with (.*)$/ do |social|
  social = social.downcase
  user = Authentication.find_by_provider(social).user
  assert_equal "valid@example.com", user.email
  assert_equal 1, user.authentications.count
  assert_equal social, user.authentications.first.provider
end

Then /there should be no (.*) account$/ do |social|
  assert_nil Authentication.find_by_provider(social.downcase)
end

Then /I am correctly signed in/ do
  user = User.find_by_email('valid@example.com')
  assert_equal "I Am User", user.name
end

Then /I am remembered/ do
  user = User.find_by_email('valid@example.com')
  assert_equal Time.zone.today, user.remember_created_at.to_date
  assert_equal 20, user.remember_token.length
end

Then /^I do (not )?have avatar$/ do |without_avatar|
  user = User.last
  if without_avatar
    assert !user.avatar.any_url_exists?
  else
    assert user.avatar.any_url_exists?
  end
end

Then  /^I should not be relogged as other user$/ do
  current_path = URI.parse(current_url).path
  assert_equal edit_user_registration_path, current_path

end

Given /^the (.*) OAuth request with email is successful$/ do |social|
  mock_successful_authentication_with_provider(social, {info: {email: "#{social.downcase}@example.com"}})
end
