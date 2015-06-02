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
    find('input[@type="submit"]').click
  end
end

Then /^#{capture_model} should be connected to selected industries$/ do |model|
  object = model!(model)
  expected_industries = (User === object) ? ["Computer Science", "Telecommunication"] : ["IT", "Telecommunication"]
  assert_equal expected_industries, object.industries.pluck(:name).reject { |name| name.include?('Industry ') }
end

When /^I update company settings$/ do
  fill_in "company_name", with: "Updated name"
  fill_in "company_url", with: "http://updated-url.example.com"
  fill_in "company_email", with: "updated@example.com"
  fill_in "company_description", with: "this is updated description"
  within('form[@id="edit_company"]') do
    find('input[@type="submit"]').click
  end
end

When /^I update payouts settings$/ do
  fill_in "company_payments_mailing_address_attributes_address", with: "Adelaide, South Australia, Australia"
  fill_in "company_paypal_merchant_account_attributes_email", with: "paypal-update@example.com"
  find('input[@type="submit"]').click
end

Given /^paypal gateway is properly configured$/ do
  CountryPaymentGateway.destroy_all
  @paypal_gateway = FactoryGirl.create(:country_payment_gateway, payment_gateway: FactoryGirl.create(:paypal_payment_gateway), country_alpha2_code: Company.last.iso_country_code).payment_gateway
end

Then /^The company payouts settings should be updated$/ do
  company = model!("the company")
  assert_equal "Adelaide SA, Australia", company.mailing_address
  assert_equal 1, company.reload.merchant_accounts.count
  assert_equal({ 'email' => "paypal-update@example.com" }, company.merchant_accounts.first.try(:data))
  assert_equal @paypal_gateway.id, company.reload.merchant_accounts.first.payment_gateway_id
end

Then /^The company should be updated$/ do
  company = model!("the company")
  assert_equal "Updated name", company.name
  assert_equal "http://updated-url.example.com", company.url
  assert_equal "updated@example.com", company.email
  assert_equal "this is updated description", company.description
end

When /^I enable white label settings$/ do
  find('.company_white_label_enabled label.checkbox').click
end

When /^I update company white label settings$/ do
  fill_in "company_theme_attributes_contact_email", with: "test@domain.lvh.me"
  fill_in "company_theme_attributes_support_email", with: "test@domain.lvh.me"
  fill_in "company_domain_attributes_name", with: "domain.lvh.me"
  find(:css, 'input[type=submit]').click
end

Then /^The company white label settings should be updated$/ do
  company = model!("the company")
  assert_equal "domain.lvh.me", company.reload.domain.try(:name)
end
