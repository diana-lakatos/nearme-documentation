Rails.application.config.marketplace_error_logger = Rails.env.test? ? MarketplaceErrorLogger::DummyLogger.new : MarketplaceErrorLogger::ActiveRecordLogger.new
