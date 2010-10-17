Given (/^I am logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)
  # FUUUUUUUUUUUUUUUUUUUUUUU
  ENV['CURRENT_USER_ID'] = user.id.to_s
end

Then /^I should be logged out$/ do
  Then %{I should see "Login"}
end

Given /^I search for "([^"]*)"$/ do |text|
  steps %{
    And I fill in "q" with "#{text}"
    And I press "submit"
  }
end

When(/^I log in as #{capture_model} with Twitter$/) do |user_instance|
  Given %{I am logged in as #{user_instance}}
   When %{I go to the login page}
end

Then(/^I should be logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)
  ENV['CURRENT_USER_ID'].should == user.id.to_s
end
