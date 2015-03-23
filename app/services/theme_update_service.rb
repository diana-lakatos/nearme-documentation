class ThemeUpdateService

  def initialize(theme)
    @theme = theme
  end

  def update(theme_params)
    @theme_original_support_email = @theme.support_email
    if @theme.update_attributes(theme_params)
      update_support_email_in_workflows

      true
    else
      false
    end
  end

  private

  def update_support_email_in_workflows
    WorkflowAlert.where(from: @theme_original_support_email).update_all(from: @theme.support_email)
    WorkflowAlert.where(reply_to: @theme_original_support_email).update_all(reply_to: @theme.support_email)
  end

end
