And(/^default language exists$/) do
  Locale.create instance_id: Instance.last.id, code: 'en', primary: true
end

And(/^another languages exists$/) do
  Locale.create instance_id: Instance.last.id, code: 'cs'
  Locale.create instance_id: Instance.last.id, code: 'pl'
end

Given(/^default language is not English$/) do
  Locale.find_by(code: 'cs').update_attribute :primary, true
end

And(/^we have translations in place$/) do
  Utils::EnLocalesSeeder.new.go!
  FactoryGirl.create(:translation, locale: 'cs', key: 'top_navbar.log_in', value: 'Přihlásit se')
  FactoryGirl.create(:translation, locale: 'pl', key: 'top_navbar.log_in', value: 'Zaloguj się',
                     instance_id: Instance.first.id)

  FactoryGirl.create(:translation, locale: 'cs', key: 'top_navbar.messages', value: 'Zprávy')
  FactoryGirl.create(:translation, locale: 'pl', key: 'top_navbar.messages', value: 'Wiadomości',
                     instance_id: Instance.first.id)
end

And /^(?:|I )change language to "([^"]*)"$/ do |language|
  visit root_path(language: language)
end

And(/^I change language to not existing one$/) do
  visit root_path(language: 'fr')
end

And(/^I reload page without language parameter$/) do
  visit root_path
end

Given /^#{capture_model} sets his language preferences to "([^"]*)"$/ do |model, language|
  model!(model).update_attribute :language, language
end

Then /^Language should be "([^"]*)"$/ do |language|
  assert_equal language.to_sym, I18n.locale
end
