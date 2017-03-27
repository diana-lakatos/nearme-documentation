# frozen_string_literal: true
class WorkflowStep::UserWorkflow::PromotedToAdmin < WorkflowStep::UserWorkflow::BaseStep
  def initialize(user_id, admin_id)
    @user = User.find(user_id)
    @creator = User.find(admin_id)
  end

  def enquirer
    @user
  end

  def lister
    @creator
  end

  # user_who_was_promoted:
  #   User object
  # user_who_promoted:
  #   User object
  def data
    { user_who_was_promoted: @user, user_who_promoted: @creator }
  end

  def workflow_triggered_by
    @creator
  end
end
