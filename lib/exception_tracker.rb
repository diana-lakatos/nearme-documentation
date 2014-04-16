module ExceptionTracker
  def self.track_exception(exception)
    return if DesksnearMe::Application.config.silence_raygun_notification
    Raygun.configuration.failsafe_logger = true
    Raygun.track_exception(exception)
    Raygun.configuration.failsafe_logger = false
  end
end
