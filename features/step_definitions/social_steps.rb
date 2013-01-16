Before do
  disable_remote_http
end

Given /^the (.*) OAuth request is successful$/ do |social|
  mock_successful_authentication_with_provider(social)
end

Given /^the (.*) OAuth request is unsuccessful$/ do |social|
  mock_unsuccessful_authentication_with_provider(social)
end

Given /^Existing User with email "([^"]*)"$/ do |email|
  @user = User.new({:email => email, :name => 'Name', :password => 'password'})
  @user.save!
end

Given /^I am logged in as the User with email "([^"]*)"$/ do |email|
  @user = User.find_by_email(email)
  login @user
end


