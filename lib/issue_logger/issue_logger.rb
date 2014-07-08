class IssueLogger
  def self.log_issue(subject, customer_email, body)
    perform_log_issue(subject, customer_email, body)
  end

  def self.perform_log_issue(subject, customer_email, body)
    Rails.logger.warn "ISSUE: #{PlatformContext.current.to_h if PlatformContext.current}: #{{:subject => subject, :customer_email => customer_email, :body => body}.inspect}"
  end

  def self.in_debug_mode?
    true #!Rails.env.production?
  end
end
