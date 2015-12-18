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

  def name_with_affiliation
    if properties.try(:is_intel) == true
      "#{name} <span>(Intel)</span>".html_safe
    else
      name
    end
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

  def display_address
    content_tag :p, object.current_address.address, class: 'location' if object.current_address
  end

  def has_friends
    @count.nil? ? @count = !friends.count.zero? : @count
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

  private

  def user_messages_decorator_for(instance)
    @user_messages_decorator ||= UserMessagesDecorator.new(user_messages, object)
  end

  def social_connections_cache
    @social_connections_cache ||= self.social_connections
  end
end
