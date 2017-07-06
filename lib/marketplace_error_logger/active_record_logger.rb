module MarketplaceErrorLogger
  class ActiveRecordLogger < BaseLogger
    def log_issue(error_type, message, options = {})
      ::MarketplaceError.create!(error_type: error_type, message: message, stacktrace: options[:stacktrace], url: options[:url])
      after_log_issue(error_type, message, options)
    end
  end
end
