class MixpanelApiJob < Job
  def after_initialize(mixpanel, method, *args)
    @mixpanel = mixpanel 
    @method = method
    @args = args
  end

  def perform
    @mixpanel.send(@method, *@args) if DesksnearMe::Application.config.perform_mixpanel_requests
  end

end
