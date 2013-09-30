class MixpanelApiJob < Job
  def initialize(mixpanel, method, *args)
    @mixpanel = mixpanel 
    @method = method
    @args = args
  end

  def perform
    @mixpanel.send(@method, *@args)
  end

end
