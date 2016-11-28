Given /^Alerts for sign up exist$/ do
  Utils::DefaultAlertsCreator::SignUpCreator.new.create_email_verification_email!
end

Given /^form configuration includes custom attribute$/ do
=begin
# I was too eager to add it, but will be needed ;)
  binding.pry
  FactoryGirl.create(:form_component_with_user_custom_attributes, form_componentable: model!('the transactable_type_listing'))
  fc = FormConfiguration.where(name: 'Default Signup').first
  fc.update_attribute(:configuration, fc.configuration.deep_merge({
    default_profile: {
      properties: {
        user_custom_attribute: {
          validation: {
            presence: {}
          }
        }
      }
    }
  }))
=end
end

Then /^(?:|I )should see "([^"]*)" platform name$/ do |text|
  page.should have_content("#{text} #{model!("instance").name}")
end

