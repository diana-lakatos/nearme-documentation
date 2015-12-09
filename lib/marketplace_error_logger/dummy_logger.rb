module MarketplaceErrorLogger
  class DummyLogger < BaseLogger
    def log_issue(error_type, message, options = {})
      Rails.logger.warn "[MarketplaceErrorLogger::Dummy] [#{error_type}]: #{message} | #{options[:stacktrace]}"
      after_log_issue(error_type, message, options)
    end
  end
end

