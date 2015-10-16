module ActivityFeedService::Helpers
  module_function

  FOLLOWED_WHITELIST = %w(User Topic Project)
  EVENTS_PER_PAGE = 10
  FOLLOWED_PER_PAGE = 15

  def object_identifier_for(object)
    "#{object.class.name}_#{object.id}"
  end
end
