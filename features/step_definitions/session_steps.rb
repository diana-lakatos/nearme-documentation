Given (/^I am logged in as #{capture_model}$/) do |user_instance|
  Given %{the Twitter OAuth request is successful}
  visit "/auth/twitter"
  user = model!(user_instance)
  auth = Factory.create(:authentication, :user => user)
  stub_twitter_successful_access_token
  stub_twitter_verify_credentials_for(:twitter_username => auth.uid, :twitter_id => auth.id)
  visit "/auth/twitter/callback?oauth_token=this_need_not_be_real&oauth_verifier=verifier"
  
  # # FUUUUUUUUUUUUUUUUUUUUUUU
  # ENV['CURRENT_USER_ID'] = user.id.to_s
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
