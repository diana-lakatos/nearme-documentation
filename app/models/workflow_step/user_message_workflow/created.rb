class WorkflowStep::UserMessageWorkflow::Created < WorkflowStep::UserMessageWorkflow::BaseStep
  def callback_to_prepare_data_for_check
    @user_message.body = nil
  end

  def callback_to_adjust_data_after_check(rendered_view)
    @user_message.reload
    @user_message.body = @user_message.body.try(:truncate, 160 - rendered_view.body.size)
  end
end
