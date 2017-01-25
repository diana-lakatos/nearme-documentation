Given /^a documents upload with requirement mandatory exists$/ do
  @documents_upload = FactoryGirl.create(:enabled_documents_upload, requirement: DocumentsUpload::REQUIREMENTS[0])
end

Given (/^a documents upload is mandatory$/) do
  DocumentsUpload.update_all(requirement: DocumentsUpload::REQUIREMENTS[0])
  UploadObligation.update_all(level: UploadObligation::LEVELS[0])
end

Given (/^a documents upload is optional$/) do
  DocumentsUpload.update_all(requirement: DocumentsUpload::REQUIREMENTS[1])
  UploadObligation.update_all(level: UploadObligation::LEVELS[1])
end

Given (/^a documents upload is vendor decides$/) do
  DocumentsUpload.update_all(requirement: DocumentsUpload::REQUIREMENTS[2])
  UploadObligation.update_all(level: UploadObligation::LEVELS[2])
end

And (/^I visit the listing page$/) do
  visit(Transactable.first.decorate.show_path)
end

And (/^I book product$/) do
  click_button "Book"
end

And (/^I make booking request$/) do
  PaymentGateway.any_instance.stubs(:gateway_authorize).returns(OpenStruct.new({ authorization: '12345', success?: true }))
  PaymentGateway.any_instance.stubs(:gateway_capture).returns(ActiveMerchant::Billing::Response.new(true, 'OK', { "id" => '12345' }))
  click_button "Request Booking"
end

And (/^I enter data in the credit card form$/) do
  fill_in 'order_payment_attributes_credit_card_attributes_first_name', with: 'FirstName'
  fill_in 'order_payment_attributes_credit_card_attributes_last_name', with: 'LastName'
  fill_in 'order_payment_attributes_credit_card_attributes_number', :with => "4242424242424242"
  select '12', from: 'order_payment_attributes_credit_card_attributes_month', visible: false
  select '2020', from: 'order_payment_attributes_credit_card_attributes_year', visible: false
  fill_in 'order_payment_attributes_credit_card_attributes_verification_value', :with => '411'
end

And (/^I should see error file can't be blank$/) do
  page.should have_content("file can't be blank")
end

And (/^I choose file$/) do
  page.execute_script('$("#order_payment_documents_attributes_0_file").show();')
  attach_file('order_payment_documents_attributes_0_file', "#{Rails.root}/features/fixtures/photos/boss's desk.jpg")
end

Then (/^I should see page with booking requests without files$/) do
  page.should_not have_selector(".payment-documents")
  page.should have_content("Your reservation has been made!")
end

Then (/^I should see page with booking requests with files$/) do
  page.should have_selector(".payment-documents li")
  page.should have_content("Your reservation has been made!")
end

Then (/^I can not see section Required Documents$/) do
  page.should_not have_content("Required Documents ")
end

Given (/^a upload_obligation exists for listing$/) do
  if Location.first.listings.first.upload_obligation.blank?
    Location.first.listings.first.create_upload_obligation({level: UploadObligation::LEVELS[2]})
  end
end

Given /^a payment_documents are turned on for reservation_type$/ do
  fc = TransactableType.first.reservation_type.form_components.first
  fc.form_fields << {"reservation" => "payment_documents"}
  fc.save
end

Given (/^a document_requirements exist for listing$/) do
  document_requirement = Location.first.listings.first.document_requirements.first
  if document_requirement.blank?
    Location.first.listings.first.document_requirements << FactoryGirl.create(
      :document_requirement, label: "Passport", description: "Provide your passport")
  end
end

Given (/^a upload_obligation exists as required$/) do
  UploadObligation.update_all(level: UploadObligation::LEVELS[0])
end

Given (/^a document requirement exists as optional$/) do
  UploadObligation.update_all(level: UploadObligation::LEVELS[1])
end

Given (/^a document requirement exists as not required$/) do
  UploadObligation.update_all(level: UploadObligation::LEVELS[2])
end

