class WorkflowStep::ActivityEventsWorkflow::BaseStep < WorkflowStep::BaseStep
  attr_reader :summary_data

  def initialize(summary_data, user_id)
    @user = User.find_by(id: user_id)
    @summary_data = summary_data.deep_stringify_keys
  end

  def enquirer
    @user
  end

  def data
    {
      enquirer: @user,
      summary_data: summary_data
    }
  end

  def workflow_type
    'activity_events_summary'
  end

  def should_be_processed?
    @user.present?
  end

  def workflow_triggered_by
    @user
  end
end
