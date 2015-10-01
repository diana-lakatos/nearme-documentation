module ActivityFeedService::Helpers
  module_function

  FOLLOWED_WHITELIST = %w(User Topic Project)

  def object_identifier_for(object)
    "#{object.class.name}_#{object.id}"
  end
end
