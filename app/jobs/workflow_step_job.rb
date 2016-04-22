class WorkflowStepJob < Job
  include Job::HighPriority

  def after_initialize(step_class, *args)
    @step_class = step_class
    @args = args
  end

  def perform
    @step_class.new(*@args).invoke!
  end
end
