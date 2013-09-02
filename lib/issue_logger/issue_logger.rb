class IssueLogger
  def self.log_issue(subject, customer_email, body)
    perform_log_issue(subject, customer_email, body)
  end

  def self.perform_log_issue(subject, customer_email, body)
    if self.in_debug_mode?
      Rails.logger.info "IssueLogger.log_issue: #{{:subject => subject, :customer_email => customer_email, :body => body}.inspect}"
    else
      Desk.create_interaction(:interaction_subject => subject, :customer_email => customer_email, :interaction_body => body)
    end
  end

  def self.in_debug_mode?
    !Rails.env.production?
  end
end
