class GoogleAnalyticsApiJob < Job
  def initialize(http_caller, method, *args)
    @http_caller = http_caller
    @method = method
    @args = args
  end

  def perform
    @http_caller.send(@method, *@args)
  end

end
