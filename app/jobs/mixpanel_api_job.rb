class MixpanelApiJob < Job
  def after_initialize(mixpanel, method, *args)
    @mixpanel = mixpanel 
    @method = method
    @args = args
  end

  def perform
    @sanitized_args = @args.utf8_convert_sanitize
    @mixpanel.send(@method, *@sanitized_args) if DesksnearMe::Application.config.perform_mixpanel_requests
  end

end
