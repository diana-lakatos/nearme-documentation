When /^I upload avatar$/ do
  avatar = File.join(Rails.root, *%w[features fixtures photos], "intern chair.jpg")
  attach_file(:avatar, avatar)
end

When /^I select industries for (.*)$/ do |object|
  if(object=='user')
    within('select[@id="user_industry_ids"]') do
      select "Computer Science"
      select "Telecommunication"
    end
  elsif(object=='company')
    within('select[@id="user_companies_attributes_0_industry_ids"]') do
      select "IT"
      select "Telecommunication"
    end
  end
    within('form[@id="edit_'+object+'"]') do
      find('input[@type="submit"]').click
    end
end

Then /^I should be connected to selected industries$/ do
  assert_equal ["Computer Science", "Telecommunication"], model!("the user").industries.pluck(:name)
end

Then /^Company should be connected to selected industries$/ do
  assert_equal ["IT", "Telecommunication"], model!("the company").industries.pluck(:name)
end

Then /^I should not see company settings$/ do
  assert !page.has_selector?('#edit_company')
end

Then /^I should see company settings$/ do
  assert page.has_selector?('#edit_company')
end

When /^I update company settings$/ do
  fill_in "user_companies_attributes_0_name", with: "Updated name"
  fill_in "user_companies_attributes_0_url", with: "http://updated-url.example.com"
  fill_in "user_companies_attributes_0_email", with: "updated@example.com"
  fill_in "user_companies_attributes_0_description", with: "this is updated description"
  fill_in "user_companies_attributes_0_mailing_address", with: "mail-update@example.com"
  fill_in "user_companies_attributes_0_paypal_email", with: "paypal-update@example.com"
  within('form[@id="edit_company"]') do
    find('input[@type="submit"]').click
  end
end

Then /^The company should be updated$/ do
  company = model!("the company")
  assert_equal "Updated name", company.name
  assert_equal "http://updated-url.example.com", company.url
  assert_equal "updated@example.com", company.email
  assert_equal "this is updated description", company.description
  assert_equal "mail-update@example.com", company.mailing_address
  assert_equal "paypal-update@example.com", company.paypal_email
end
