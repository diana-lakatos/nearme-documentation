When /^I select industries for user and company$/ do
  within('select[@id="user_industry_ids"]') do
    select "Computer Science"
    select "Telecommunication"
  end
  within('select[@id="user_companies_attributes_0_industry_ids"]') do
    select "IT"
    select "Telecommunication"
  end
  within('form[@id="edit_user"]') do
    find('input[@type="submit"]').click
  end
end

Then /^I should be connected to selected industries$/ do 
  assert_equal ["Computer Science", "Telecommunication"], User.first.industries.pluck(:name)
end

Then /^Company should be connected to selected industries$/ do 
  assert_equal ["IT", "Telecommunication"], User.first.companies.first.industries.pluck(:name)
end

Then /^I should not see company settings$/ do
  assert !page.has_selector?('div.company_settings')
end

Then /^I should see company settings$/ do
  assert page.has_selector?('div.company_settings')
end

When /^I update company settings$/ do 
  fill_in "user_companies_attributes_0_name", with: "Updated name"
  fill_in "user_companies_attributes_0_url", with: "http://updated-url.example.com"
  fill_in "user_companies_attributes_0_email", with: "updated@example.com"
  fill_in "user_companies_attributes_0_description", with: "this is updated description"
  fill_in "user_companies_attributes_0_mailing_address", with: "mail-update@example.com"
  fill_in "user_companies_attributes_0_paypal_email", with: "paypal-update@example.com"
  within('form[@id="edit_user"]') do
    find('input[@type="submit"]').click
  end
end

Then /^The company should be updated$/ do
  company = User.first.companies.first
  assert_equal "Updated name", company.name
  assert_equal "http://updated-url.example.com", company.url
  assert_equal "updated@example.com", company.email
  assert_equal "this is updated description", company.description
  assert_equal "mail-update@example.com", company.mailing_address
  assert_equal "paypal-update@example.com", company.paypal_email
end
