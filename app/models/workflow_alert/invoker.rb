class WorkflowAlert::Invoker
  def initialize(workflow_alert)
    @workflow_alert = workflow_alert
  end

  def invoke!(step)
    if @workflow_alert.delay.to_i > 0
      processor_class.enqueue_later(@workflow_alert.delay.minutes.from_now)
    else
      processor_class.enqueue
    end.send(processor_method, step, @workflow_alert.id)
  end

  protected

  def processor_class
    fail NotImplementedError
  end

  def processor_method
    fail NotImplementedError
  end
end
