When /^I create a company$/ do
  visit new_company_path
  fill_in "Your company name", with: @company_name = "Company"
  fill_in "Company website URL", with: "http://example.com"
  fill_in "Company email", with: "hello@example.com"
  fill_in "Company description", with: "And I'm having the time of my life!"
  click_link_or_button "Create My Company"
end

Then /^I can select that company when creating locations$/ do
  visit new_location_path
  select @company_name, from: "Company"
end
