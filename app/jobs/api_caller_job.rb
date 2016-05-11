class ApiCallerJob < Job
  include Job::HighPriority

  def after_initialize(caller_class, caller_method, *args)
    @caller_class = caller_class
    @caller_method = caller_method
    @args = args
  end

  def perform
    raise "Unknown PlatformContext" if PlatformContext.current.nil?
    @caller_class.send(@caller_method, *@args).try(:deliver)
  end

  def self.priority
    0
  end

end
