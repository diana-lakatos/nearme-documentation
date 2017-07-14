# frozen_string_literal: true
module Notification
  class SendNotification
    # the reason for t is to allow user
    # to not use quotes in mp builder conf file
    CONDITION_TRUES = %w(true t).freeze

    class << self
      def call(notification:, form:, params:)
        notification_class(notification).new(notification: notification,
                                             form: form,
                                             params: params).call
      end

      def notification_class(notification)
        case notification
        when EmailNotification
          Notification::SendEmailNotification
        when SmsNotification
          Notification::SendSmsNotification
        when ApiCallNotification
          Notification::SendApiCallNotification
        else
          raise NotImplementedError, "Unknown notification type #{notification.class.name}"
        end
      end
    end

    def initialize(notification:, form:, params:)
      @notification = notification
      @form = form
      @params = params
    end

    def call
      return unless invokable?
      return unless should_trigger?
      set_locale
      valid? ? send : log_error
    end

    protected

    def log_error
      MarketplaceLogger.error(MarketplaceErrorLogger::BaseLogger::NOTIFICATION_ERROR, validation_message)
    end

    def invokable?
      # this config will be set to true in production and test environment, false in application.rb
      return true if Rails.application.config.force_sending_all_workflow_alerts
      return true if self.class.name.include?('SendEmailNotification') # for backwards compatibility :/
      current_instance&.enable_sms_and_api_workflow_alerts_on_staging?
    end

    def should_trigger?
      CONDITION_TRUES.include? Liquify::ParsedValue.new(@notification.trigger_condition,
                                                        form: @form,
                                                        params: @params).to_s
    end

    def send
      raise NotImplementedError, 'must implement abstract method `send`'
    end

    def set_locale
      I18n.locale = locale
    end

    def liquify(value)
      Liquify::ParsedValue.new(value, form: @form, params: @params).to_s
    end

    def locale
      liquify(@notification.locale).presence || current_instance&.primary_locale
    end

    def current_instance
      PlatformContext.current&.instance
    end

    # TODO: extract to Validator?
    def valid?
      mandatory_fields.none? { |field| liquify(@notification.send(field)).blank? }
    end

    def validation_message
      missing_fields = mandatory_fields.each_with_object([]) do |field, array|
        array << field if liquify(@notification.send(field)).blank?
      end
      if missing_fields.any?
        %(
#{@notification.name} was not sent due to missing field(s): #{missing_fields.join(', ')}.
Raw values:
#{missing_fields.map { |missing_field| "\t#{@notification.send(missing_field)}" }}
        )
      else
        ''
      end
    end

    def mandatory_fields
      raise NotImplementedError, 'must implement abstract method `mandatory_fields`'
    end
  end
end
