Given /^an exist documents upload$/ do
  user = User.find_by(email: 'valid@example.com')
  documents_upload = FactoryGirl.create(:enabled_documents_upload, instance: user.instance)
end

When(/^I create documents upload$/) do
  page.execute_script('$("input[data-activate-upload-files]").bootstrapSwitch("toggleState")')
  page.should have_content(I18n.t('instance_admin.settings.documents_upload.form.documents_can_be'))
  choose('documents_upload_requirement_mandatory')
  click_button I18n.t('instance_admin.settings.documents_upload.form.save_button')
end

When(/^I update documents upload$/) do
  choose('documents_upload_requirement_vendor_decides')
  click_button I18n.t('instance_admin.settings.documents_upload.form.save_button')
end

Then(/^I should see updated documents upload$/) do
  page.should have_css('.alert.success')
  page.should have_content(I18n.t('flash_messages.instance_admin.settings.settings_updated'))
end
