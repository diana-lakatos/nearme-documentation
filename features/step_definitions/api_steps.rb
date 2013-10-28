Given /^no organizations$/ do

end

Given /^I am an authenticated api user( and my name is (.*?))?( and my email is (.*?))?$/ do |with_name, name, with_email, email|
  attrs = {}
  attrs[:email] = email if with_email
  attrs[:name] = name if with_name
  @user = FactoryGirl.create(:user, attrs)
  post "/v1/authentication", { email: @user.email, password: 'password' }.to_json
  fail "User was not authenticated" unless last_response.ok?
  @user.reload
end

Given /^an amenity named (.*)$/ do |name|
  FactoryGirl.create(:amenity, name: name)
end

When /^I send a(n authenticated)? POST request to "(.*?)":$/ do |authenticated, url, body|
  if url.match(/:id/) && plural_resource = url.match(/^(\w+)\/.*/)
    this_resource = instance_variable_get("@#{plural_resource.captures.first.singularize}")
    parsed_url = url.gsub(/:(\w+)/) {|message| this_resource.send $1}
  else
    parsed_url = url
  end

  header 'Authorization', user.authentication_token if authenticated
  @response = post "/v1/#{parsed_url}", ERB.new(body).result(binding)
end

When /^I send a(n authenticated)? GET request for "(.*?)"$/ do |authenticated, url|
  header 'Authorization', user.authentication_token if authenticated
  @response = get "/v1/#{url}"
end

When /^I send a(n authenticated)? search request with a bounding box around New Zealand$/ do |authenticated|
  header 'Authorization', user.authentication_token if authenticated
  api_search({ bounding_box: "New Zealand" })
end

Then /^I receive a response with (\d+) status code$/ do |status_code|
  last_response.status.should == status_code.to_i
end

Then /^the response does (not )?include the listing in (.*)$/ do |negative, city|
  includes_result = results_listings.any? do |listing|
      listing[:company_name].include?(city)
  end

  if negative
    includes_result.should be_false
  else
    includes_result.should be_true
  end
end

Then /^the response contains an empty organizations list$/ do
  result["organizations"].empty?.should be_true
end
