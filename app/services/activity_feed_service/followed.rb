module ActivityFeedService::Followed
  extend ActiveSupport::Concern

  included do
    has_many :activity_feed_subscriptions, as: :followed

    def feed_followers(params)
      ActivityFeedSubscription.where(followed: self).active.follower_as_objects(params)
    end

    def followers
      ActivityFeedSubscription.where(followed: self).active
    end

    # Decorator

    def feed_followed_name
      self.try(:name).presence || self.try(:title).presence || self.try(:id)
    end
  end
end
