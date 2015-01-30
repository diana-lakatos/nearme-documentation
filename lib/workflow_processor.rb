module WorkflowProcessor

  def self.invoke_alerts(event, options)
    Workflow.for_workflow_type(event_type.to_s).workflow_steps.for_event(event.step).includes(:workflow_alerts).each do |workflow_step|
      workflow_step.workflow_alerts.each do |workflow_alert|
        process_workflow_alert(workflow_alert, options)
      end
    end
  end

  def self.process_workflow_alert(workflow_alert, options)
    case workflow_alert.alert_type
    when 'email'
      EmailAlertProcessor.new(workflow_alert, options).process
    when 'sms'
      SmsAlertProcessor.new(workflow_alert, options).process
    else
      raise "Unknown alert type: #{workflow_alert.alert_type}"
    end
  end

end
