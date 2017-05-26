# frozen_string_literal: true
require 'test_helper'

module Api
  module V4
    module User
      class UserMessagesControllerTest < ActionController::TestCase
        setup do
          @recipient = FactoryGirl.create(:user)
          @user = FactoryGirl.create(:user)
          sign_in @user
        end

        should 'be able to add user message and go to message page' do
          assert_difference 'UserMessage.count' do
            post :create, form_configuration_id: form_configuration.id,
              user_id: @recipient.id,
              user_message: {
                body: 'foo'
              }
          end

          assert_redirected_to dashboard_user_message_path(UserMessage.last.id)
        end

        should 'add user message with custom attribute' do
          FactoryGirl.create(
            :custom_attribute,
            name: :foo, target: UserMessageType.default, attribute_type: 'string'
          )
          assert_difference 'UserMessage.count' do
            post :create, form_configuration_id: form_configuration_with_custom_attribute.id,
              user_id: @recipient.id,
              user_message: {
                body: 'some body',
                properties: {
                  foo: 'bar'
                }
              }
          end

          user_message = UserMessage.last
          assert_equal('some body', user_message.body)
          assert_equal({ 'foo' => 'bar' }, user_message.properties.to_h)
        end

        protected

        def form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'user_message_form',
            base_form: 'UserMessageForm',
            configuration: {
              body: {
                validation: {
                  presence: true
                }
              }
            },
            return_to: "{% if form.model.id %}{{ 'dashboard_user_message_path' | generate_url: id: form.model.id }}{% endif %}"
          )
        end

        def form_configuration_with_custom_attribute
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'user_message_form',
            base_form: 'UserMessageForm',
            configuration: {
              body: {
                validation: {
                  presence: true
                }
              },
              properties: {
                foo: {
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
