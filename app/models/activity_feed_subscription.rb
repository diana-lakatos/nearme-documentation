class ActivityFeedSubscription < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :followed, polymorphic: true, counter_cache: :followers_count
  belongs_to :follower, class_name: 'User', counter_cache: :following_count

  scope :find_subscription, lambda { |follower, followed|
    where(follower: follower, followed: followed)
  }

  scope :with_user_id_as_follower, lambda { |user_id, klass|
    klass
      .joins(
        ActiveRecord::Base.send(
          :sanitize_sql_array,
          ["LEFT JOIN activity_feed_subscriptions afs ON afs.followed_id = #{klass.table_name}.id AND afs.followed_type = '#{klass.name}' AND follower_id = ?", user_id]
        )
      )
      .select("#{klass.table_name}.*, afs.id IS NOT NULL as is_followed")
  }

  validates_uniqueness_of :followed_identifier, scope: [:follower_id]
  validates_uniqueness_of :follower_id, scope: [:followed_id, :followed_type]
  validates_inclusion_of :followed_type, in: ActivityFeedService::Helpers::FOLLOWED_WHITELIST

  before_save :set_followed_identifier

  after_create :trigger_workflow_alert_for_new_follow

  def set_followed_identifier
    self.followed_identifier = ActivityFeedService::Helpers.object_identifier_for(followed)
  end

  after_commit :create_feed_event, on: :create
  def create_feed_event
    event = "user_followed_#{followed.class.name.underscore}"
    ActivityFeedService.create_event(event, followed, [follower], self)
  end

  after_commit :destroy_events_related_to_this_subscription, on: :destroy
  def destroy_events_related_to_this_subscription
    ActivityFeedEvent.where(event_source_id: id_was, event_source_type: 'ActivityFeedSubscription').destroy_all
  end

  def trigger_workflow_alert_for_new_follow
    klass = case followed_type
    when 'Transactable'
      WorkflowStep::FollowerWorkflow::UserFollowedTransactable
    when 'User'
      WorkflowStep::FollowerWorkflow::UserFollowedUser
    end
    WorkflowStepJob.perform(klass, id) if klass.present?
    true
  end
end
