# frozen_string_literal: true
Given(/^I am logged in as #{capture_model}$/) do |user_instance|
  login model!(user_instance)
end

When(/^I log in as #{capture_model}$/) do |user_instance|
  login model!(user_instance)
end

When /^an anonymous user attempts to sign up with email (.*)$/ do |email|
  sign_up_manually(email: email)
end

Given /^I am logged in manually$/ do
  sign_up_manually
end

Then /^I should be logged out$/ do
  step 'I should see "Log In"'
end

Then(/^I should be logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)

  # NB: this covers the Admin interface as well as the public interface and the instance admin interface
  page.should have_xpath("//a[contains(@data-user, \"#{user.first_name}\")]")
  step 'I should see "Log Out"'
end

Then /^I should( not)? be redirected to the previous search page$/ do |without_redirect|
  current_path = URI.parse(current_url)
  if without_redirect
    assert_equal new_user_session_path, current_path.path
  else
    assert_equal search_path(q: 'Auckland'), [current_path.path, '?', current_path.query].join
  end
end

Then /^I should see an indication I've just signed in$/ do
  step 'I should see "You have signed up successfully."'
end

Then /^a new account is not created$/ do
  assert_equal 1, User.count
end

Then /^I should get verification email$/ do
  user = User.last
  last_email_for(user.email).subject.should =~ Regexp.new("#{user.first_name}, please verify your .+ email")
end

Then /^I log out$/ do
  log_out
end
