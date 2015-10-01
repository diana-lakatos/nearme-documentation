module ActivityFeedService::Callbacks

  extend ActiveSupport::Concern

  included do
    EVENT_WHITELIST = %w(
      project_file_added
      project_new_comment
      user_commented_on_project
      user_followed_user
      user_followed_topic
      user_followed_project
      user_updated_status
      topic_project_created
      topic_idz_content_pushed_to_page
    ).freeze

    validates_inclusion_of :event, in: EVENT_WHITELIST

    def update_affected_objects(*arguments)
      objects = arguments.map { |argument| ActivityFeedService::Helpers.object_identifier_for(argument) }
      follower = [ActivityFeedService::Helpers.object_identifier_for(follower)]
      self.affected_objects_identifiers = follower + objects
    end
  end
end
