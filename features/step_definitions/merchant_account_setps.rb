And (/^I remove all payment gateways$/) do
  PaymentGateway.destroy_all
end

When(/^I update Stripe merchant form$/) do
  account_type = page.find("#merchant_account_account_type option", :visible => false)
  account_type.set('individual')
  account_type.select_option
  page.find("#merchant_account_account_type option", :visible => false).set('individual')
  fill_in 'merchant_account_bank_routing_number', with: '110000000'
  fill_in 'merchant_account_bank_account_number', with: '000123456789'
  fill_in 'merchant_account_first_name', with: 'Tomasz'
  fill_in 'merchant_account_last_name', with: 'Lemkowski'
  fill_in 'merchant_account_owners_attributes_0_dob_formated', with: '01/22/1990'
  fill_in 'merchant_account_current_address_attributes_address', with: '1600 Amphitheatre Parkway, Mountain View, CA 94043, USA'
  fill_in 'merchant_account_personal_id_number', with: '694-07-7618'
  attach_file('merchant_account_owners_attributes_0_document', File.absolute_path('./public/favicon.png'))
  page.check('merchant_account_tos')
  find('input[type="submit"]').click
end

Then(/^summary table should be displayed$/) do
  expect(page).to have_css("table.table-simple")
  assert_equal '********6789', find(:xpath, "//table/tbody/tr[4]/td[2]").text
end

And(/^(.*) merchant account should be created$/) do |state|
  assert_equal state, MerchantAccount.last.state
end

And(/^I set Stripe to respond with (.*)$/) do |error|
  stub_request(:post, /https:\/\/api.stripe.com\/v1\/accounts*/).to_return(status: 200, body: account_create_respone_with_error(error))
  stub_request(:post, 'https://uploads.stripe.com/v1/files').to_return(status: 200, body: file_response_body)
end

def account_create_respone_with_error(error)
  response = File.read(File.join(Rails.root, 'features', 'fixtures', 'stripe_responses', "account_create.json"))
  response.gsub!("\"disabled_reason\":null", "\"disabled_reason\":\"#{error}\"")
  response
end

def file_response_body
  {
    "id": "file_19OUWJK2MWM5GsIT08B2h36X",
    "object": "file_upload",
    "created": 1481213599,
    "purpose": "dispute_evidence",
    "size": 9863,
    "type": "png"
  }.to_json
end

Then(/^Stripe (.*) error should be presented to user$/) do |error|
  error_message = case error
  when 'rejected.fraud' then 'This account is rejected due to suspected fraud or illegal activity.'
  end

  expect(page).to have_css("div.errors-global")
  page.first('div.errors-global').text.should match(error_message)
end

And /^there should be no errors$/ do
  expect(page).not_to have_css("div.errors-global")
end

Given /^failed_stripe_connect_merchant_account is persisted$/ do
  m = FactoryGirl.build(:failed_stripe_connect_merchant_account)
  m.company = model('company')
  m.skip_validation = true
  m.stubs('onboard!' => true)
  m.save(validate: false)
end

Then /^I should see all persisted errors$/ do
  expect(page).to have_css("div.errors-global")
  ['This account is rejected for some other reason.', 'Please update your document', 'Scan failed for other reason.'].each do |error|
    page.first('div.errors-global').text.should match(error)
  end
end



