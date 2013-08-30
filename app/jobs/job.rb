# Base class for our Jobs.
#
# This encapsulates 'job' units of work and any background execution semantics,
# that they may or may not have.
#
# Usage:
#
#   Define a Job:
#
#   class MyJob < Job
#     def initialize(arg1, arg2)
#       @arg1 = arg1
#       @arg2 = arg2
#     end
#
#     def perform
#       # Execute the Job
#     end
#   end
#
#   Using a Job throughout the application:
#
#   MyJob.perform(arg1, arg2)
#
#   Note:
#     * Other application code is only concerned that the responsibility for
#       certain logic is handled by the Job.
#     * That is, it is not concerned that the Job executes asynchronously, or
#       how it does that.
class Job
  def self.perform(*args)
    if run_in_background?
      perform_async(*args)
    else
      new(*args).perform
    end
  end

  def self.perform_later(when_perform, *args)
    if run_in_background?
      Delayed::Job.enqueue new(*args), :run_at => get_performing_time(when_perform)
    else
      # this is completely unnecessary, but still we want this to be invoked to catch errors in tests
      get_performing_time(when_perform)
      new(*args).perform
    end
  end

  def self.perform_async(*args)
    Delayed::Job.enqueue new(*args)
  end

  def self.run_in_background?
    # By default all jobs perform asynchronously except in Development and Test
    # environments.
    !(Rails.env.development? || Rails.env.test?)
  end

  def self.get_performing_time(when_perform)
    performing_time = case when_perform.class.to_s
      when "Fixnum"
        Time.zone.now + when_perform
      when "ActiveSupport::TimeWithZone"
        when_perform
      when "Time"
        raise "Job.perform_later: use TimeWithZone (i.e. Time.zone.now instead of Time.now etc)"
      else
        raise "Job.perform_later: Unknown first argument, must be number of seconds or time with zone - was #{when_perform} (#{when_perform.class})"
    end
    raise "Job.perform_later: makes no sense to perform later and giving argument 1 as past" if performing_time < Time.zone.now
    performing_time
  end
end

