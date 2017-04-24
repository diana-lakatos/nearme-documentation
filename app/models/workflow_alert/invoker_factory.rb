# frozen_string_literal: true
class WorkflowAlert::InvokerFactory
  def self.get_invoker(alert, metadata: {})
    case alert.alert_type
    when 'email'
      WorkflowAlert::EmailInvoker.new(alert, metadata: metadata)
    when 'sms'
      WorkflowAlert::SmsInvoker.new(alert, metadata: metadata)
    when 'api_call'
      WorkflowAlert::ApiCallInvoker.new(alert, metadata: metadata)
    else
      raise NotImplementedError, "Unknown alert type: #{alert.alert_type}"
    end
  end
end
