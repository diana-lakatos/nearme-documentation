class WorkflowAlert::EmailInvoker < WorkflowAlert::Invoker
  protected

  def processor_class
    CustomMailer
  end

  def processor_method
    :custom_mail
  end
end
