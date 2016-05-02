# Base class for sending sms
#
# This encapsulates logic behind sending sms, whether to do it immediately, or in background. In the second case,
# it communicates with SmsNotifier class to determine when the sms should be sent [ i.e. after 1 hour, 10 days etc ]
#
# Arguments:
#
# arg1 - sms class
# arg2 - method that sends sms
# next args - arguments for the method from arg2
#
# Example Usage:
#
# There are two possiblies. We can use Job::SyntaxEnhancer to invoke like this:
#
#  ReservationSmsNotifier.enqueue.notify_host_with_confirmation(@reservation)
#
# or just do
#
#   SmsJob.perform(ReservationSmsNotifier, :notify_host_with_confirmation, @reservation)
#
# If we want to send sms at some point in the future, we do
#
#   ReservationSmsNotifier.enqueue_later(5.hours.from_now).notify_host_with_confirmation(@reservation)
#
#  or
#
#   SmsJob.perform_later(5.hours.from_now, ReservationSmsNotifier, :notify_host_with_confirmation, @reservation)
#
#   the first argument must be either ActiveSupport::TimeWithZone or Fixnum (number of seconds, for example 5.hours).
#   Please note that using Time.now instead of Time.zone.now will raise error

class SmsNotifierJob < Job
  include Job::HighPriority

  def after_initialize(sms_notifier_class, sms_notifier_method, *args)
    @sms_notifier_class = sms_notifier_class
    @sms_notifier_method = sms_notifier_method
    @args = args
  end

  def perform
    raise "Unknown PlatformContext" if PlatformContext.current.nil?
    @sms_notifier_class.send(:"#{@sms_notifier_method}", *@args).tap do |sms_notifier|
      if sms_notifier.deliver!
        WorkflowAlertLogger.new(WorkflowAlert.find(@args[1])).log!
      end
    end
  end

  def self.priority
    0
  end
end
