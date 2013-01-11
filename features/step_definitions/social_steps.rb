Before do
  disable_remote_http
end

Given /^the (.*) OAuth request is successful$/ do |social|
  send("stub_#{social.downcase}_request_token".to_sym)
end

Given /^Existing User with email "([^"]*)"$/ do |email|
  @user = User.new({:email => email, :name => 'Name', :password => 'password'})
  @user.save!
end

Given /^I am logged in as the User with email "([^"]*)"$/ do |email|
  @user = User.find_by_email(email)
  login @user
end


When 'I grant access to the $social_app application for $social_user user "$social_username" with ID $social_id' do |social_app, social_user, social_username, social_id|
  send("stub_#{social_app.downcase}_successful_access_token".to_sym)
  send("stub_#{social_app.downcase}_verify_credentials_for".to_sym,"#{social_app.downcase}_username".to_sym => social_username, "#{social_app.downcase}_id".to_sym => social_id)
  visit "/auth/#{social_app.downcase}/callback?oauth_token=this_need_not_be_real&oauth_verifier=verifier"
end

