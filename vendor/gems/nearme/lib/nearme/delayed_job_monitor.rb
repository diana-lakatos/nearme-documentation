require 'active_support'
require 'active_record'
require 'delayed_job'
require 'delayed_job_active_record'

class DelayedJobMonitor
  class DelayedJobValidationFailed < StandardError; end
  include ActiveModel::Validations

  PENDING_TASK_LIMIT = 200
  TASK_TIME_LIMIT    = 5 # minutes

  validate :pending_tasks_limit
  validate :running_task_time_limit

  def self.perform
    new.tap do |state|
      failure(state.errors.full_messages) unless state.valid?
    end
  end

  def self.failure(errors)
    abort errors.join("\n")
  end

  def initialize
    establish_connection
  end

  private

  def running_task_time_limit
    errors.add :base, 'Currently running task is taking too long.' if long_running_task_number > 0
  end

  def pending_tasks_limit
    errors.add :base, 'Too many pending tasks in the DJ queues.' if overloaded_queues.any?
  end

  def overloaded_queues
    ActiveRecord::Base.connection.execute(
      "select queue, count(1) as queue_size from delayed_jobs where attempts = 0 and locked_at is null and run_at < now() group by queue having count(1) > %d" % PENDING_TASK_LIMIT
    )
  end

  def long_running_task_number
    Delayed::Job
      .where('locked_at is not null')
      .where("(now() - locked_at)  > interval '? minutes'", TASK_TIME_LIMIT)
      .count
  end

  def establish_connection
    ::ActiveRecord::Base.establish_connection database_config
  end

  def database_config
    YAML.load_file(database_file).fetch(ENV['RAILS_ENV'])
  end

  def database_file
    ::File.expand_path('../../../../../../config/database.yml', __FILE__)
  end
end
