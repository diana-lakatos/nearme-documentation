# frozen_string_literal: true
class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def user_message_recipient(_current_user)
    object
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.name, profile_path(user_message.thread_context.slug)
  end

  def display_address
    content_tag :p, object.current_address.address, class: 'location' if object.current_address
  end

  def feed_follow_term(object)
    feed_subscribed_to?(object) ? I18n.t('activity_feed.verbs.unfollow') : I18n.t('activity_feed.verbs.follow')
  end

  def feed_follow_url(object)
    url_helpers = Rails.application.routes.url_helpers
    params = { id: object.id, type: object.class.name }

    feed_subscribed_to?(object) ? url_helpers.unfollow_path(params) : url_helpers.follow_path(params)
  end

  def feed_follow_http_method(object)
    feed_subscribed_to?(object) ? 'delete' : 'post'
  end

  def show_path
    profile_path(slug)
  end
end
