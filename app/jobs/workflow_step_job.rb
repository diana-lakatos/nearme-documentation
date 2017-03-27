# frozen_string_literal: true
class WorkflowStepJob < Job
  include Job::HighPriority

  def self.perform(*args, as: system_user)
    super(*args, as: as)
  end

  def self.system_user
    nil # need better representation of system user
  end

  def after_initialize(step_class, *args, as:)
    @step_class = step_class
    @args = args
    @as = as
  end

  def perform
    @step_class.new(*@args).invoke!(@as)
  end

  def self.priority
    0
  end
end
