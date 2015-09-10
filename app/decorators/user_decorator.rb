class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def current_location_and_industry
    result = []
    result << current_location if current_location.present?
    result << industries.map(&:name).join(", ") if industries.present?
    result.join(" | ")
  end

  def unread_user_message_threads_for(instance)
    user_messages_decorator_for(instance).inbox.unread
  end

  def social_connections_for(provider)
    social_connections_cache.select{|c| c.provider == provider}.first
  end

  def user_message_recipient
    object
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.name, profile_path(user_message.thread_context.slug)
  end

  def has_spree_role?(role)
    true
  end

  def display_location
    object.current_location ? object.country_name : object.current_location
  end

  def has_friends
    @count.nil? ? @count = !friends.count.zero? : @count
  end

  private

  def user_messages_decorator_for(instance)
    @user_messages_decorator ||= UserMessagesDecorator.new(user_messages, object)
  end

  def social_connections_cache
    @social_connections_cache ||= self.social_connections
  end
end
