class ActivityFeedSubscription < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :followed, polymorphic: true, counter_cache: :followers_count
  belongs_to :follower, class_name: 'User', counter_cache: :following_count

  scope :find_subscription, ->(follower, followed) {
    where(follower: follower, followed: followed)
  }

  validates_uniqueness_of :followed_identifier, scope: [:follower_id]
  validates_uniqueness_of :follower_id, scope: [:followed_id, :followed_type]
  validates_inclusion_of :followed_type, in: ActivityFeedService::Helpers::FOLLOWED_WHITELIST

  before_save :set_followed_identifier
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
    ActivityFeedEvent.where(event_source_id: self.id_was, event_source_type: "ActivityFeedSubscription").destroy_all
  end
end
