
Given (/^I am logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)
  auth = Factory.create(:authentication, :user => user)
  stub_twitter_request_token
  visit "/auth/twitter"
  stub_twitter_successful_access_token(auth.uid)
  stub_twitter_verify_credentials_for(:twitter_username => auth.uid, :twitter_id => auth.id)
  visit "/auth/twitter/callback?oauth_token=this_need_not_be_real&oauth_verifier=verifier"
end

Then /^I should be logged out$/ do
  Then %{I should see "Sign In"}
end

Given /^I search for "([^"]*)"$/ do |text|
  if text =~ /adelaide/
    WebMock.stub_request(:get, %r|.*maps\.google\.com.*| ).to_return({:body => File.read(File.join(Rails.root, *%w[features fixtures gmaps adelaide.json]))})
  end
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
  Then %{I should see "Logout"}
end

