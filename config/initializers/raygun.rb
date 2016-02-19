Raygun.setup do |config|
  config.api_key = Rails.application.config.raygun_api_key
  config.version = Rails.application.config.app_version

  Raygun.configuration.silence_reporting = DesksnearMe::Application.config.silence_raygun_notification
  config.filter_parameters = Rails.application.config.filter_parameters

  config.ignore << ['Transactable::NotFound', 'Listing::NotFound', 'Location::NotFound', 'Page::NotFound', 'Reservation::NotFound', 'RecurringBooking::NotFound', 'UserBlog::NotFound', 'MarketplaceErrorLogger::Error', 'ActionController::UnknownFormat', 'OAuth::Unauthorized']
end
