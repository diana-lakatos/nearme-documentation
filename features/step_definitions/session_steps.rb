
Given (/^I am logged in as #{capture_model}$/) do |user_instance|
  login model!(user_instance)
end

When /^I log in as a user who is a member of that organization$/ do
  user = FactoryGirl.create(:user, organizations: [model!('organization')])
  login user
end

Then /^I should be logged out$/ do
  Then %{I should see "Login"}
end

When(/^I log in as #{capture_model} with Twitter$/) do |user_instance|
  Given %{I am logged in as #{user_instance}}
   When %{I go to the login page}
end

Then(/^I should be logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)
  Then %{I should see "Logout"}
end

Then /^#{capture_model} should have password "([^"]*)"$/ do |user_instance, password|
  user = model!(user_instance)
  user.valid_password?(password).should be_true
end
