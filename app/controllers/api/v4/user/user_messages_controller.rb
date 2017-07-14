# frozen_string_literal: true
module Api
  module V4
    module User
      class UserMessagesController < Api::V4::User::BaseController
        def create
          SubmitForm.new(
            form_configuration: form_configuration,
            form: message_form,
            params: form_params,
            current_user: current_user
          ).tap do |submit_form|
            submit_form.add_success_observer(SubmitForm::CallMethodOnModel.new(:send_notification))
          end.call
          respond(message_form)
        end

        protected

        def message_form
          @message_form ||= form_configuration.build(user_message)
        end

        def user_message
          message = current_user.authored_messages.new(author: current_user, user_message_type: UserMessageType.default)
          message.set_message_context_from_request_params(params, current_user)
          message
        end

        def form_params
          params[:user_message].presence || {}
        end
      end
    end
  end
end
