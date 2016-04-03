class MarketplaceLogger
  def self.error(*args)
    Rails.application.config.marketplace_error_logger.log_issue(*args)
  end
end
