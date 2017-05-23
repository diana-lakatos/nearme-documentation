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
      end
    end
  end
end
