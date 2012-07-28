
Given (/^I am logged in as #{capture_model}$/) do |user_instance|
  user = model!(user_instance)
  auth = FactoryGirl.create(:authentication, :user => user)
  OmniAuth.config.add_mock(:twitter, {:uid => auth.uid})
  visit "/auth/twitter"
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

