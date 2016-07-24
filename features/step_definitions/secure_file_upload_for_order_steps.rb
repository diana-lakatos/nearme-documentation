And /^User has order on payment step$/ do
  @order = FactoryGirl.create(:order_waiting_for_payment, line_items_count: 1, user: user)
end

And /^Translation for default label exists$/ do
  FactoryGirl.create(:translation, key: 'upload_documents.file.default.label', value: 'Secure Document Upload')
end

When /^User visits order payment page$/ do
  visit "/orders/#{@order.number}/checkout/payment"
end

Then /^Sees default file label and field for upload$/ do
  page.should have_css('.document-requirements')
  page.should have_css('.btn-upload-payment-document', count: 1)
  page.should have_content(I18n.t('upload_documents.file.default.label'))
end

When /^User clicks on Next button$/ do
  click_button "Next"
end

When /^User clicks on Complete Checkout button$/ do
  click_button "Complete Checkout"
end

Then /^Sees file cannot be blank$/ do
  page.should have_css('.document-requirements .error-block', count: 1)
  page.should have_content("can't be blank")
end

Then /^Sees no error message for file$/ do
  page.should_not have_css('.document-requirements .error-block')
end

Then /^Attach file$/ do
  attach_secure_file('0')
end

Then /^Attach second file$/ do
  attach_secure_file('1')
end

And /^File should be saved$/ do
  visit dashboard_orders_path
  page.should have_css(".payment-documents li", count: 1)
  page.should have_content(Attachable::PaymentDocument.first.payment_document_info.document_requirement.label)
end

And /^File should not be saved$/ do
  visit dashboard_orders_path
  page.should_not have_css(".payment-documents")
end

Then /^Should not see default file label and field for upload$/ do
  page.should_not have_css('.btn-upload-payment-document', count: 1)
  page.should_not have_content(I18n.t('upload_documents.file.default.label'))
end

Then /^User should see two labels and file fields$/ do
  page.should have_content(@document_requirement_first.label)
  page.should have_content(@document_requirement_second.label)
  page.should_not have_content(I18n.t('upload_documents.file.default.label'))
end

And /^Two files should be saved$/ do
  visit dashboard_orders_path
  page.should have_css(".payment-documents li", count: 2)
  page.should have_content(Attachable::PaymentDocument.first.payment_document_info.document_requirement.label, count: 1)
  page.should have_content(Attachable::PaymentDocument.second.payment_document_info.document_requirement.label, count: 1)
end

Given /^Document upload is disabled$/ do
  @documents_upload.update(enabled: false)
end

def attach_secure_file(number)
  page.execute_script("$('#order_payment_documents_attributes_#{number}_file').show();")
  attach_file("order_payment_documents_attributes_#{number}_file", "#{Rails.root}/features/fixtures/photos/boss's desk.jpg")
end
