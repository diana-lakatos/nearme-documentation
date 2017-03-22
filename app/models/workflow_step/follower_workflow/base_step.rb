class WorkflowStep::FollowerWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(activity_feed_subscription_id)
    @activity_feed_subscription = ActivityFeedSubscription.find_by(id: activity_feed_subscription_id)
    @followed = @activity_feed_subscription.try(:followed)
    @user = @activity_feed_subscription.try(:follower)
  end

  def enquirer
    @user
  end

  def should_be_processed?
    @activity_feed_subscription.present?
  end

  def workflow_type
    'follower_workflow'
  end

  def workflow_triggered_by
    enquirer
  end
end
