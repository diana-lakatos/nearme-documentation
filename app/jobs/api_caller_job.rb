class ApiCallerJob < Job
  def after_initialize(caller_class, caller_method, *args)
    @caller_class = caller_class
    @caller_method = caller_method
    @args = args
  end

  def perform
    raise "Unknown PlatformContext" if PlatformContext.current.nil?
    @caller_class.send(@caller_method, *@args).deliver
  end

  def self.priority
    0
  end

end
