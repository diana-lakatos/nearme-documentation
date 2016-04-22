class MixpanelApiJob < Job
  def after_initialize(mixpanel, method, *args)
    @mixpanel = mixpanel
    @method = method
    @args = args
  end

  def perform
    return unless DesksnearMe::Application.config.perform_mixpanel_requests

    @sanitized_args = @args.utf8_convert_sanitize
    @mixpanel.send(@method, *@sanitized_args)
  end
end
