Before do
  disable_remote_http
end

Given /^the (.*) OAuth request is successful$/ do |social|
  OmniAuth.config.mock_auth[social.downcase.to_sym] = OmniAuth::AuthHash.new({
    :provider => social.downcase,
    :uid => '123545',
    :info => { 
      # those parameters need to correspond to information needed in app/helpers/authentications_helper
      :name => "#{social} name",
      :image => "donthave.j[g",
      :nickname => 'omnitester', #for twitter
      :urls => {
        :public_profile => "htttp://myprofile.com", #linkedin
        :link => "htttp://myprofile.com",#facebook
      }
    }
  })
end

Given /^the (.*) OAuth request is unsuccessful$/ do |social|
  OmniAuth.config.logger = Rails.logger #otherwise the error goes to STDOUT
  OmniAuth.config.mock_auth[social.downcase.to_sym] = :testing_invalid_credentials
end

Given /^Existing User with email "([^"]*)"$/ do |email|
  @user = User.new({:email => email, :name => 'Name', :password => 'password'})
  @user.save!
end

Given /^I am logged in as the User with email "([^"]*)"$/ do |email|
  @user = User.find_by_email(email)
  login @user
end


