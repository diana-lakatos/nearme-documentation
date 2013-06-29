When /^I upload avatar$/ do
  avatar = File.join(Rails.root, *%w[features fixtures photos], "intern chair.jpg")
  attach_file('avatar', avatar)
end

When /^I select industries for #{capture_model}$/ do |model|
  object = model!(model)
  if(object.class.to_s=='User')
    within('select[@id="user_industry_ids"]') do
      select "Computer Science"
      select "Telecommunication"
    end
  elsif(object.class.to_s=='Company')
    within('select[@id="user_companies_attributes_0_industry_ids"]') do
      select "IT"
      select "Telecommunication"
    end
  end
  within('form[@id="edit_'+object.class.to_s.downcase+'"]') do
    find('input[@type="submit"]').click
  end
end

Then /^#{capture_model} should be connected to selected industries$/ do |model|
  object = model!(model)
  expected_industries = (object.class.to_s=='User') ? ["Computer Science", "Telecommunication"] : ["IT", "Telecommunication"]
  assert_equal expected_industries, object.industries.pluck(:name).reject { |name| name.include?('Industry ') }
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
