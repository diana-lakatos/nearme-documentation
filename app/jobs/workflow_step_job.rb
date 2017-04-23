# frozen_string_literal: true
class WorkflowStepJob < Job
  include Job::HighPriority

  def self.perform(*args, as: system_user, metadata: {})
    super(*args, as: as, metadata: metadata)
  end

  def self.system_user
    nil # need better representation of system user
  end

  def after_initialize(step_class, *args, metadata: {}, as:)
    @step_class = step_class
    @args = args
    @as = as
    @metadata = metadata
  end

  def perform
    @step_class.new(*@args).invoke!(as: @as, metadata: @metadata)
  end

  def self.priority
    0
  end
end
