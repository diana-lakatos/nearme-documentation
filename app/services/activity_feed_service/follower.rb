module ActivityFeedService::Follower
  extend ActiveSupport::Concern

  included do
    has_many :activity_feed_subscriptions, as: :follower

    def feed_following(params)
      users = ActivityFeedSubscription.where(follower: self, followed_type: "User").active
      projects = ActivityFeedSubscription.where(follower: self, followed_type: "Project").active
      topics = ActivityFeedSubscription.where(follower: self, followed_type: "Topic").active

      OpenStruct.new(
        users: users.followed_as_objects(params),
        users_count: users.count, 
        projects: projects.followed_as_objects(params),
        projects_count: projects.count,
        topics: topics.followed_as_objects(params),
        topics_count: topics.count
      )
    end

    def feed_subscribed_to?(object)
      ActivityFeedSubscription.find_subscription(self, object).active.any?
    end

    def feed_follow!(object)
      subscription = ActivityFeedSubscription.find_subscription(self, object).first_or_create!
      subscription.activate!
    end

    def feed_unfollow!(object)
      ActivityFeedSubscription.find_subscription(self, object).deactivate!
    end

    # decorator

    def feed_follower_name
      self.name.presence || self.title.presence || self.id
    end

    def feed_follow_term(object)
      feed_subscribed_to?(object) ? I18n.t("activity_feed.verbs.unfollow") : I18n.t("activity_feed.verbs.follow")
    end

    def feed_follow_url(object)
      url_helpers = Rails.application.routes.url_helpers
      params = { id: object.id, type: object.class.name }

      feed_subscribed_to?(object) ? url_helpers.unfollow_path(params) : url_helpers.follow_path(params)
    end

    def feed_follow_http_method(object)
      feed_subscribed_to?(object) ? "delete" : "post"
    end
  end
end
