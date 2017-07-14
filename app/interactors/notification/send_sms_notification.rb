# frozen_string_literal: true
module Notification
  class SendSmsNotification < SendNotification
    protected

    def send
      # todo: bypassing a lot of abstraction created in CustomSmsNotifier
      # which can be deleted later on, and SmsNotifier::Message can be simplified
      # itself as well
      ::SmsNotifier::Message.new(options).deliver
    end

    def options
      @options ||= {
        to: liquify(@notification.to),
        body: liquify(@notification.content)
      }
    end

    def mandatory_fields
      %i(to content)
    end
  end
end
