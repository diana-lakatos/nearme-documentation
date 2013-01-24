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

When /^I send a(n authenticated)? search request with the query "(.*)"$/ do |authenticated, query|
  api_search({ query: query })
end

When /^I send a(n authenticated)? search request with a bounding box around New Zealand$/ do |authenticated|
  header 'Authorization', user.authentication_token if authenticated
  api_search({ bounding_box: "New Zealand" })
end

When /^I send a search request with a bounding box around (.*) and prices between \$(\d+) and \$(\d+)$/ do |location, min, max|
  api_search(bounding_box: location, price_min: min, price_max: max)
end

When /^I send a search request with a bounding box around (.*) and a minimum of (\d+) desks$/ do |location, desks|
  api_search(bounding_box: location, desks_min: desks)
end

When /^I send a search request with a bounding box around (.*) available (\d+), (\d+), and (\d+) days from now$/ do |location, first, second, third|
  api_search(bounding_box: location, dates: [ first, second, third ].map { |i| i.to_i.days.from_now })
end
Then /^I receive a response with (\d+) status code$/ do |status_code|
  last_response.status.should == status_code.to_i
end

Then /^the JSON listings should be empty$/ do
  results_listings.size.should == 0
end

Then /^the JSON should contain that listing$/ do
  listing = model!('listing')

  results_listings.size.should == 1
  result_listing = results_listings.first

  result_listing[:name].should         == listing.name
  result_listing[:company_name].should == listing.company.name
  result_listing[:address].should      == listing.address
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

Then /^the response should have the listing in (.*) with the (.*) score$/ do |city, direction|
  direction = direction == "lowest" ? 1 : -1
  results_listings.sort_by do |a|
    a[:score].to_i * direction
  end.first[:company_name].should include city
end

Then /^the response should have the listing for \$(\d+) with the (.*) score$/ do |dollars, direction|
  direction = direction == "lowest" ? 1 : -1
  results_listings.sort_by do |a|
    a[:score].to_i * direction
  end.first[:price]["amount"].to_i.should eq dollars.to_i
end
