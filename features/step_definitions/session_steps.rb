Given(/^I am logged in as #{capture_model}$/) do |user_instance|
  login model!(user_instance)
end

When(/^I log in as #{capture_model}$/) do |user_instance|
  login model!(user_instance)
end

Given /^I am logged in manually$/ do
  sign_up_manually
end

Then /^I should be logged out$/ do
  step "I should see \"Log in\""
end


Then(/^I should be logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)
  Then "I should see \"Log out\""
end

Then /^#{capture_model} should have password "([^"]*)"$/ do |user_instance, password|
  user = model!(user_instance)
  user.valid_password?(password).should be_true
end
