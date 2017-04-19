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
          profiles: {
            default: {
              properties: {
                'job_title' => {},
                'biography' => {}
              }
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
          profiles: {
            default: {
              properties: {
              }
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

    factory :form_configuration_customization do
      name 'Instance Customization'
      base_form 'CustomizationForm'
      liquid_body do
        %(
          {% form_for form, url: '/api/user/customizations', as: customization %}
            <input value="{{ form_configuration.id }}" type="hidden" name="form_configuration_id" />
            <input value="{{ page.id }}" type="hidden" name="page_id" />
            <input value="/" type="hidden" name="return_to" />
            <input value="{{ form.custom_model_type_id }}" type="hidden" name="custom_model_type_id" />

            {% input custom_model_type_id, as: hidden %}
            {% fields_for properties, form: refer_a_friend %}
              {% input enquirer_name, form: properties %}
              {% input enquirer_email, input_html-data-maskedinput: 'email', form: properties %}
            {% endfields_for %}

            {% submit 'Save' %}

          {% endform_for %}
        )
      end
      configuration do
        {
          properties: {
            enquirer_name: {
              validation: {
                presence: {}
              }
            },
            enquirer_email: {
              validation: {
                presence: {}
              }
            }
          }
        }
      end
      after(:build) do |form|
        form.workflow_steps << FactoryGirl.build(:customization_created_workflow)
      end
    end
  end
end
