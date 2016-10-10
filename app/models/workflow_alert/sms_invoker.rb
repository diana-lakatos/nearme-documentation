class WorkflowAlert::SmsInvoker < WorkflowAlert::Invoker
  protected

  def processor_class
    CustomSmsNotifier
  end

  def processor_method
    :custom_sms
  end
end
