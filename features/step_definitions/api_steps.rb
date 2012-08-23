Given /^I am not an authenticated api user$/ do
  @user.should be_nil
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

Given /^an organization named (.*)$/ do |name|
  FactoryGirl.create(:organization, name: name)
end

Given /^an organization with logo named (.*)$/ do |name|
  FactoryGirl.create(:organization_with_logo, name: name)
end

When /^I send a(n authenticated)? POST request to "(.*?)":$/ do |authenticated, url, body|
  if url.match(/:id/) && plural_resource = url.match(/^(\w+)\/.*/)
    this_resource = instance_variable_get("@#{plural_resource.captures.first.singularize}")
    parsed_url = url.gsub(/:(\w+)/) {|message| this_resource.send $1}
  else
    parsed_url = url
  end

  header 'Authorization', @user.authentication_token if authenticated
  @response = post "/v1/#{parsed_url}", body
end

When /^I send a(n authenticated)? GET request for "(.*?)"$/ do |authenticated, url|
  header 'Authorization', @user.authentication_token if authenticated
  @response = get "/v1/#{url}"
end

When /^I search for listings with that organization$/ do
    json = {
      "boundingbox" => {"start" => {"lat" => -180.0,"lon" => -180.0}, "end" => {"lat" => 180.0,"lon" => 180.0 }},
      "organizations" => [@listing.organizations.first.id]
    }
    @response = post "/v1/listings/search", json.to_json
end

Then /^I receive only listings which have that amenity$/ do
  results = parse_json(last_json)
  results["listings"].size.should == 1
  results["listings"].all? do |r|
    r["amenities"].any? { |a| a["id"] == 1 }
  end
end

Then /^I receive only listings which have that organization$/ do
  results = parse_json(last_json)
  results["listings"].size.should == 1
  results["listings"].all? do |r|
    r["organizations"].any? { |a| a["id"] == @listing.organizations.first.id }
  end
end

Then /^I receive a response with (\d+) status code$/ do |status_code|
  last_response.status.should == status_code.to_i
end

Then /^the JSON listings should be empty$/ do
  results = parse_json(last_json)
  results["listings"].size.should == 0
end

Then /^the JSON should contain that listing$/ do
  results = parse_json(last_json)
  listing = model!('listing')

  results["listings"].size.should == 1
  result_listing = results["listings"].first

  result_listing["name"].should         == listing.name
  result_listing["company_name"].should == listing.company.name
  result_listing["address"].should      == listing.address
end
