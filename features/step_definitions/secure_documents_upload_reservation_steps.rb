Given /^a documents upload with requirement mandatory exists$/ do
  @documents_upload = FactoryGirl.create(:enabled_documents_upload, requirement: DocumentsUpload::REQUIREMENTS[0])
end

Given (/^a documents upload is mandatory$/) do
  @documents_upload.update(requirement: DocumentsUpload::REQUIREMENTS[0])
end

Given (/^a documents upload is optional$/) do
  @documents_upload.update(requirement: DocumentsUpload::REQUIREMENTS[1])
end

Given (/^a documents upload is vendor decides$/) do
  @documents_upload.update(requirement: DocumentsUpload::REQUIREMENTS[2])
end

And (/^I visit the listing page$/) do
  visit(transactable_type_location_listing_path(TransactableType.first, Location.first, Location.first.listings.first))
end

And (/^I book product$/) do
  click_button "Book"
end

And (/^I make booking request$/) do
  PaymentAuthorizer.any_instance.stubs(:authorize).returns(OpenStruct.new({ token: '12345', success?: true }))
  PaymentGateway.any_instance.stubs(:gateway_capture).returns(ActiveMerchant::Billing::Response.new(true, 'OK', { "id" => '12345' }))
  click_button "Request Booking"
end

And (/^I enter data in the credit card form$/) do
  fill_in 'reservation_request_payment_credit_card_form_first_name', with: 'FirstName'
  fill_in 'reservation_request_payment_credit_card_form_last_name', with: 'LastName'
  fill_in 'reservation_request_payment_credit_card_form_number', :with => "4242424242424242"
  select '12', from: 'reservation_request_payment_credit_card_form_month', visible: false
  select '2020', from: 'reservation_request_payment_credit_card_form_year', visible: false
  fill_in 'reservation_request_payment_credit_card_form_verification_value', :with => '411'
end

And (/^I should see error file can't be blank$/) do
  page.should have_content("File cannot be empty")
end

And (/^I choose file$/) do
  page.execute_script('$("#reservation_request_reservation_payment_documents_file").show();')
  attach_file('reservation_request_reservation_payment_documents_file', "#{Rails.root}/features/fixtures/photos/boss's desk.jpg")
end

Then (/^I should see page with booking requests without files$/) do
  page.should_not have_selector(".payment-document")
  page.should have_content("Your booking was requested successfully!")
end

Then (/^I should see page with booking requests with files$/) do
  page.should have_selector(".payment-document")
  page.should have_content("Your booking was requested successfully!")
end

Then (/^I can not see section Required Documents$/) do
  page.should_not have_content("Required Documents ")
end

Given (/^a upload_obligation exists for listing$/) do
  if Location.first.listings.first.upload_obligation.blank?
    Location.first.listings.first.create_upload_obligation({level: UploadObligation::LEVELS[2]})
  end
end

Given (/^a document_requirements exist for listing$/) do
  document_requirement = Location.first.listings.first.document_requirements.first
  if document_requirement.blank?
    Location.first.listings.first.document_requirements << FactoryGirl.create(
      :document_requirement, label: "Passport", description: "Provide your passport")
  end
end

Given (/^a upload_obligation exists as required$/) do
  Location.first.listings.first.upload_obligation.update(level: UploadObligation::LEVELS[0])
end

Given (/^a document requirement exists as optional$/) do
  Location.first.listings.first.upload_obligation.update(level: UploadObligation::LEVELS[1])
end

Given (/^a document requirement exists as not required$/) do
  Location.first.listings.first.upload_obligation.update(level: UploadObligation::LEVELS[2])
end

