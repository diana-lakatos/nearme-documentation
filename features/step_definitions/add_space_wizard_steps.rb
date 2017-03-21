# frozen_string_literal: true
When /^(?:|I )follow "([^"]*)" bookable noun$/ do |link|
  click_link "#{link} #{TransactableType.first.translated_bookable_noun}"
end

When /a form configuration with custom attributes is set/ do
  FormConfiguration.where(base_form: 'UserUpdateProfileForm').destroy_all
  FactoryGirl.create(:form_configuration_default_update)
end

Then /^(?:|I )should see "([^"]*)" bookable noun$/ do |text|
  page.should have_content("#{text} #{TransactableType.first.translated_bookable_noun}")
end

Given /^I close notification$/ do
  page.find('[data-flash-message] a').click
end
