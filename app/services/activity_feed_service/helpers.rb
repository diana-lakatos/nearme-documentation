module ActivityFeedService::Helpers
  module_function

  FOLLOWED_WHITELIST = %w(User Topic Transactable Group)
  EVENTS_PER_PAGE = 10
  FOLLOWED_PER_PAGE = 15

  def object_identifier_for(object)
    class_name = object.class.name
    class_name.gsub!(/Decorator$/, '')
    "#{class_name}_#{object.id}"
  end
end
