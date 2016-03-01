class WorkflowAlert::InvokerFactory

  def self.get_invoker(alert)
    case alert.alert_type
    when 'email'
      WorkflowAlert::EmailInvoker.new(alert)
    when 'sms'
      WorkflowAlert::SmsInvoker.new(alert)
    when 'api_call'
      WorkflowAlert::ApiCallInvoker.new(alert)
    else
      raise NotImplementedError.new("Unknown alert type: #{alert.alert_type}")
    end
  end

end
