# frozen_string_literal: true
require 'test_helper'

module Api
  module V4
    module User
      class CustomizationsControllerTest < ActionController::TestCase
        setup do
          @user = FactoryGirl.create(:user)
          @model_type = FactoryGirl.create(:custom_model_type, name: 'Dummy Model', instance_profile_types: [PlatformContext.current.instance.default_profile_type])
          FactoryGirl.create(:custom_attribute, name: 'model_attr', target: @model_type)
          w = Workflow.create!(name: 'Custom Model Workflow', workflow_type: 'customization_workflow')
          ws = w.workflow_steps.create!(associated_class: WorkflowStep::CustomizationWorkflow::Created, name: 'Custom Model Step')
          InstanceView.create!(body: 'Hello {{ lister.first_name }}', path: 'custom_mailer/custom_model_email', format: 'html', handler: 'liquid', view_type: 'email', locales: Locale.all)
          ws.workflow_alerts.create!(name: 'send email', alert_type: 'email', recipient_type: 'lister', template_path: 'custom_mailer/custom_model_email', subject: 'hello {{ lister.first_name }}', layout_path: 'layouts/mailer', from: 'a@example.com', reply_to: 'a.example.com')
          form_configuration.workflow_steps << ws
          form_configuration.save!
        end

        context 'with authorized user' do
          setup do
            sign_in @user
          end

          should 'send workflow alert for customization' do
            assert_difference 'Customization.count' do
              assert_difference 'ActionMailer::Base.deliveries.size' do
                post :create, { custom_model_type_id: @model_type.id, form_configuration_id: form_configuration.id, form: { properties: { model_attr: 'hello' } } }
              end
            end
            c = Customization.last
            assert_equal @user.id, c.user_id
            assert_equal 'hello', c.properties.model_attr
            email = ActionMailer::Base.deliveries.last
            assert_contains @user.email, email.to
            assert_contains "Hello #{@user.first_name}", email.html_part.body
            assert_contains "hello #{@user.first_name}", email.subject
          end
        end

        protected

        def form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'customization_form',
            base_form: 'CustomizationForm',
            configuration: {
              properties: {
                model_attr: {
                  validation: {
                    presence: true
                  }
                }
              }
            }
          )
        end
      end
    end
  end
end
