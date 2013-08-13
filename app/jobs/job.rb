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
    # By default all jobs perform asynchronously except in Development and Test
    # environments.
    if Rails.env.development? || Rails.env.test?
      new(*args).perform
    else
      perform_async *args
    end
  end

  def self.perform_async(*args)
    Delayed::Job.enqueue new(*args)
  end
end

