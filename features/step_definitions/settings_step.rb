When /^I upload avatar$/ do
  avatar = File.join(Rails.root, *%w[features fixtures photos], "intern chair.jpg")
  attach_file('avatar', avatar)
end

When /^I select industries for #{capture_model}$/ do |model|
  object = model!(model)
  if(User === object)
    within('select[@id="user_industry_ids"]') do
      select "Computer Science"
      select "Telecommunication"
    end
  elsif(Company === object)
    within('select[@id="company_industry_ids"]') do
      select "IT"
      select "Telecommunication"
    end
  end
  within('form[@id="edit_'+object.class.to_s.downcase+'"]') do
    if Company === object
      find('div[@data-white-label-settings-container] input[@type="submit"]').click
    else
      find('input[@type="submit"]').click
    end
  end
end

Then /^#{capture_model} should be connected to selected industries$/ do |model|
  object = model!(model)
  expected_industries = (User === object) ? ["Computer Science", "Telecommunication"] : ["IT", "Telecommunication"]
  assert_equal expected_industries, object.industries.pluck(:name).reject { |name| name.include?('Industry ') }
end

Then /^I should not see company settings$/ do
  assert !page.has_selector?('#edit_company')
end

Then /^I should see company settings$/ do
  assert page.has_selector?('#edit_company')
end

When /^I update company settings$/ do
  fill_in "company_name", with: "Updated name"
  fill_in "company_url", with: "http://updated-url.example.com"
  fill_in "company_email", with: "updated@example.com"
  fill_in "company_description", with: "this is updated description"
  fill_in "company_mailing_address", with: "mail-update@example.com"
  fill_in "company_paypal_email", with: "paypal-update@example.com"
  within('form[@id="edit_company"] div[data-white-label-settings-container]') do
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

When /^I enable white label settings$/ do
  page.find(:css, 'div[data-white-label-settings-container] .switch label').click 
end

When /^I update company white label settings$/ do
  fill_in "company_domain_attributes_name", with: "domain.lvh.me"
  within(:css, 'form[id=edit_company] div[data-white-label-settings-container]') do
    find(:css, 'input[type=submit]').click
  end
end

Then /^The company white label settings should be updated$/ do
  company = model!("the company")
  assert_equal "domain.lvh.me", company.domain.name
end
