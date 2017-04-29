# Base class for sending emails
#
# This encapsulates logic behind sending email, whether to do it immediately, or in background. In the second case,
# it communicates with Mailer class to determine when the email should be sent [ i.e. after 1 hour, 10 days etc ]
#
# Arguments:
#
# arg1 - mailer class
# arg2 - method that sends email
# next args - arguments for the method from arg2
#
# Example Usage:
#
# There are two possiblies. We can use Job::MailerJobSyntaxEnhancer to invoke like this:
#
#  ReservationMailer.enqueue.notify_host_with_confirmation(@reservation)
#
# or just do
#
#   MailerJob.perform(ReservationMailer, :notify_host_with_confirmation, @reservation)
#
# If we want to send email at some point in the future, we do
#
#   ReservationMailer.enqueue_later(5.hours.from_now).notify_host_with_confirmation(@reservation)
#
#  or
#
#   MailerJob.perform_later(5.hours.from_now, ReservationMailer, :notify_host_with_confirmation, @reservation)
#
#   the first argument must be either ActiveSupport::TimeWithZone or Fixnum (number of seconds, for example 5.hours).
#   Please note that using Time.now instead of Time.zone.now will raise error

class MailerJob < Job
  include Job::HighPriority

  def after_initialize(mailer_class, mailer_method, *args)
    @mailer_class = mailer_class
    @mailer_method = mailer_method
    @args = args
  end

  def perform
    fail 'Unknown PlatformContext' if PlatformContext.current.nil?
    begin
      @mailer_class.send(@mailer_method, *@args).deliver
    rescue Net::SMTPSyntaxError
      Rails.application.config.marketplace_error_logger.log_issue(MarketplaceErrorLogger::BaseLogger::MAILER_ERROR, 'Mail was not sent due to SMTP syntax error')
    rescue Net::OpenTimeout
      Rails.application.config.marketplace_error_logger.log_issue(MarketplaceErrorLogger::BaseLogger::MAILER_ERROR, 'Mail was not sent due to timeout')
    end
  end

  def self.priority
    0
  end
end
