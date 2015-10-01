class ActivityFeedSubscription < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :followed, polymorphic: true
  belongs_to :follower, class_name: 'User'

  scope :find_subscription, ->(follower, followed) {
    where(follower: follower, followed: followed)
  }

  scope :active, ->{ where(active: true) }

  validates_uniqueness_of :followed_identifier, scope: [:follower_id]

  validates_inclusion_of :followed_type, in: ActivityFeedService::Helpers::FOLLOWED_WHITELIST

  has_many :comments, as: :commentable

  before_save :set_followed_identifier
  def set_followed_identifier
    self.followed_identifier = ActivityFeedService::Helpers.object_identifier_for(followed)
  end

  after_commit :create_feed_event, on: :create
  def create_feed_event
    event = "user_followed_#{followed.class.name.underscore}"
    ActivityFeedService.create_event(event, followed, [follower], self)
  end

  after_commit :increase_counters, on: :create
  def increase_counters
    update_counters(:+)
  end

  after_commit :decrease_counters, on: :destroy
  def decrease_counters
    update_counters(:-)
  end

  %w(followed follower).each do |attribute|
    define_singleton_method("#{attribute}_as_objects") do |params|
      page = params[:page].to_i || 1
      per = ActivityFeedService::EVENTS_PER_PAGE
      offset = (page == 0) ? 0 : page * per - per

      self.order(created_at: :desc).offset(offset).limit(per).map(&attribute.to_sym)
    end
  end


  def activate!
    update_column(:active, true)
  end

  def deactivate!
    update_all(:active, false)
  end

  def self.activate!
    update_all(active: true)
  end

  def self.deactivate!
    update_all(active: false)
  end

  private

  def update_counters(operation)
    followed.update_column(:followers_count, followed.followers_count.send(operation, 1))
    follower.update_column(:following_count, follower.following_count.send(operation, 1))
  end
end
