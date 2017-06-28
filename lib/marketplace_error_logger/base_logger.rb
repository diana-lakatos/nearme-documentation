# frozen_string_literal: true
# MarketplaceErrorLogger is used to log issues specific to current marketplace
#
# It's main job is to store notifications for MarketplaceOwner about errors
# caused by various misconfiguration. This includes for example errors about
# SMS-es not being sent due to issues with Twilio etc.
module MarketplaceErrorLogger
  class BaseLogger
    # constants used for 'error type' field
    NOTIFICATION_ERROR = 'Notification Not Sent'
    SMS_ERROR = 'SMS Not Sent'
    REFUND_ERROR = 'Refund failed'
    IMAP_ERROR = 'Email receiver failed'
    MAILER_ERROR = 'Mailer Not Sent'
    SELLER_ATTACHMENTS_ERROR = 'Seller Attachments Error'
    API_CALL_ERROR = 'Api Call failed'

    def log_issue(_error_type, _message, _options = {})
      raise NotImplementedError
    end

    # callback that is invoked after logging an issue
    def after_log_issue(_error_type, _message, options = {})
      raise MarketplaceErrorLogger::Error, "#{e.message} (error code=#{e.code})" if options[:raise]
    end
  end
  # Error of this class is used to re-raise error that has been already logged. Usually
  # We want this in order to re-try background job.
  class Error < StandardError; end
end
