class ThemeUpdateService

  def initialize(theme)
    @theme = theme
  end

  def update(theme_params)
    if @theme.update_attributes(theme_params)
      update_support_email_in_workflows

      true
    else
      false
    end
  end

  private

  def update_support_email_in_workflows
    # Maybe not the best in terms of performance but this doesn't happen often
    # and premature optimization is also evil
    workflow_alerts = Workflow.where(:workflow_type => 'support').collect(&:workflow_steps).flatten.collect(&:workflow_alerts).flatten
    workflow_alerts.each { |workflow_alert| workflow_alert.update_attributes(:from => @theme.support_email, :reply_to => @theme.support_email) }
  end

end
