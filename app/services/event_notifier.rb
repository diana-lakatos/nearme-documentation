class EventNotifier

  def self.notify(event_type, options = {})
    WorkflowProcessor.invoke_alerts(event_type, options)
  end

end

