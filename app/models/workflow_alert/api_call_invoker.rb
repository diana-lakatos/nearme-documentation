class WorkflowAlert::ApiCallInvoker < WorkflowAlert::Invoker

  protected

  def processor_class
    ApiCaller
  end

  def processor_method
    :call
  end

end

