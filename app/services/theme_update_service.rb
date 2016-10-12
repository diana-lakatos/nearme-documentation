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
    WorkflowAlert.update_all(from: @theme.support_email)
    WorkflowAlert.update_all(reply_to: @theme.support_email)
  end
end
