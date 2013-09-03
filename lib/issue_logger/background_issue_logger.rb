class BackgroundIssueLogger < IssueLogger
  def self.log_issue(*args)
    if self.in_debug_mode?
      super
    else
      delay.perform_log_issue(*args)
    end
  end
end
