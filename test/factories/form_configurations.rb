# frozen_string_literal: true
FactoryGirl.define do
  factory :form_configuration do
    factory :form_configuration_default_signup do
      name 'Default Signup'
      base_form 'UserSignup::DefaultUserSignup'
      configuration do
        {
          'name' => {
            validation: {
              presence: true
            }
          }
        }
      end
    end

    factory :form_configuration_lister_signup do
      name 'Lister Signup'
      base_form 'UserSignup::ListerUserSignup'
      configuration do
        {
          'name' => {
            validation: {
              presence: true
            }
          }
        }
      end
    end

    factory :form_configuration_enquirer_signup do
      name 'Enquirer Signup'
      base_form 'UserSignup::EnquirerUserSignup'
      configuration do
        {
          'name' => {
            validation: {
              presence: true
            }
          }
        }
      end
    end

    factory :form_configuration_default_update do
      name 'Default Update'
      base_form 'UserUpdateProfileForm'
      configuration do
        {
          'public_profile' => {},
          :default_profile => {
            properties: {
              'job_title' => {},
              'biography' => {}
            }
          },
          'mobile_number' => {},
          'avatar' => {},
          'name' => {},
          'first_name' => {},
          'middle_name' => {},
          'last_name' => {},
          'country' => { property_options: { virtual: true } },
          'phone' => {},
          'language' => {},
          'time_zone' => {},
          'current_location' => {},
          'company_name' => {}
        }
      end
    end

    factory :form_configuration_default_update_minimum do
      name 'Default Update'
      base_form 'UserUpdateProfileForm'
      configuration do
        {
          'public_profile' => {},
          :default_profile => {
            properties: {
            }
          },
          'mobile_number' => {},
          'country' => { property_options: { virtual: true } },
          'phone' => {},
          'avatar' => {},
          'name' => {},
          'first_name' => {},
          'middle_name' => {},
          'last_name' => {},
          'language' => {},
          'time_zone' => {},
          'current_location' => {},
          'company_name' => {}
        }
      end
    end
  end
end
