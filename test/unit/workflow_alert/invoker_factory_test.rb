require 'test_helper'

class WorkflowStep::InvokerFactoryTest < ActiveSupport::TestCase
  should 'return email invoker for email type' do
    assert_equal WorkflowAlert::EmailInvoker, WorkflowAlert::InvokerFactory.get_invoker(stub(alert_type: 'email')).class
  end

  should 'return sms invoker for sms type' do
    assert_equal WorkflowAlert::SmsInvoker, WorkflowAlert::InvokerFactory.get_invoker(stub(alert_type: 'sms')).class
  end

  should 'return api call invoker for api call type' do
    assert_equal WorkflowAlert::ApiCallInvoker, WorkflowAlert::InvokerFactory.get_invoker(stub(alert_type: 'api_call')).class
  end

  should 'raise exception for unknown alert type' do
    assert_raise NotImplementedError do
      WorkflowAlert::InvokerFactory.get_invoker(stub(alert_type: 'unknown'))
    end
  end
end
