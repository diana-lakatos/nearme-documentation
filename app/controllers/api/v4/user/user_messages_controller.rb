# frozen_string_literal: true
module Api
  class V4::User::UserMessagesController < Api::V4::User::BaseController
    def create
      if message_form.validate(form_params)
        message_form.save
        message_form.model.send_notification
      end
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
