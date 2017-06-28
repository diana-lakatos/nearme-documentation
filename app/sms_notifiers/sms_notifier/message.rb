# frozen_string_literal: true
require 'twilio-ruby'

# Wraps sending a message via the twilio client in an interface
# similar to Mail used in ActionMailer.
class SmsNotifier
  class Message
    attr_accessor :twilio_sms
    class InvalidTwilioConfig < ::StandardError; end
    class TooLong < ::StandardError; end

    class DummyTwilioClient
      def initialize(key, secret)
        @key = key
        @secret = secret
      end

      def method_missing(method, *args)
        Rails.logger.info "Twilio #{@key}:#{@secret} - #{method}: #{args.inspect}"
        self
      end
    end

    SMS_SIZE = 160
    # see https://www.twilio.com/docs/errors/reference for details
    # 21407: This Phone Number type does not support SMS or MMS
    # 21421: PhoneNumber is invalid
    # 21601: Phone number is not a valid SMS-capable/MMS-capable inbound phone number
    # 21614: 'To' number is not a valid mobile number
    ERROR_CODES_FOR_FALLBACK = [21_407, 21_421, 21_601, 21_614].freeze

    def initialize(data)
      @data = data.reverse_merge(from: from_number)
    end

    def to
      @data[:to]
    end

    def from
      @data[:from]
    end

    def body
      @data[:body]
    end

    def platform_context
      PlatformContext.current
    end

    def fallback_email
      @data.fetch(:fallback, {}).fetch(:email, nil)
    end

    def fallback_user
      @user ||= User.where(email: fallback_email).first if fallback_email.present? && platform_context.present?
    end

    def deliver
      if valid?
        begin
          send_twilio_message
          return self
        rescue Twilio::REST::RequestError => e
          if should_fallback_to_email?(e.code)
            # if error code is caused by malfromed phone number, notify user via email if possible
            fallback_user.notify_about_wrong_phone_number if fallback_user.present?
          else
            # notify MPO about some kind of twilio issue and re-raise error to re-try background job
            MarketplaceLogger.error(
              MarketplaceErrorLogger::BaseLogger::SMS_ERROR,
              "#{e.message} (error code=#{e.code}; to number=#{@data[:to]})",
              raise: true
            )
          end
          return false
        end
      else
        false
      end
    end
    alias deliver! deliver

    private

    def should_fallback_to_email?(code)
      ERROR_CODES_FOR_FALLBACK.include?(code)
    end

    def twilio_client
      @twilio_client ||= build_twilio_client
    end

    def build_twilio_client
      raise_error_if_config_invalid
      if Rails.application.config.send_real_sms
        Twilio::REST::Client
      else
        SmsNotifier::Message::DummyTwilioClient
      end.new(config[:key], config[:secret])
    end

    def valid?
      if twilio_client.nil?
        false
      elsif @data[:body].size > SMS_SIZE
        MarketplaceLogger.error(MarketplaceErrorLogger::BaseLogger::SMS_ERROR, "Body size is longer than #{SMS_SIZE} - #{@data[:body]} (#{@data[:body].size} characters)")
        false
      else
        true
      end
    end

    def send_twilio_message
      self.twilio_sms = twilio_client.account.sms.messages.create(
        body: @data[:body],
        to: @data[:to],
        from: @data[:from]
      )
    end

    def config
      @config ||= PlatformContext.current.instance.twilio_config
    end

    def from_number
      config[:from]
    end

    def raise_error_if_config_invalid
      if config[:key].blank? || config[:secret].blank? || config[:from].blank?
        MarketplaceLogger.error(MarketplaceErrorLogger::BaseLogger::SMS_ERROR, 'Twilio configuration is missing key, secret or from number')
      end
    end
end
end
