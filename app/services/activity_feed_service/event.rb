# frozen_string_literal: true
class ActivityFeedService::Event
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  include ListingsHelper

  def controller
    ApplicationController
  end

  attr_accessor :image
  attr_accessor :text

  def initialize(event, target = '_self')
    @event = event
    @target = target
    send(event.event.to_sym)
  rescue
    self.image = nil
    self.text = nil
  end

  def user_updated_user_status
    user = @event.event_source.user
    updated = begin
                user.try(:properties).try(:[], :gender).presence
              rescue
                updated = ''
              end
    self.image = image_or_placeholder(user.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(user, :secret_name), updated: updated).html_safe
  end

  def user_updated_transactable_status
    user = @event.event_source.user
    updated = @event.event_source.updateable
    self.image = image_or_placeholder(user.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(user, :secret_name), updated: link_if_not_deleted(updated, :name)).html_safe
  end
  alias user_updated_topic_status user_updated_transactable_status

  def user_followed_user
    follower = @event.event_source.follower
    followed = @event.followed
    followed_name = followed.try(:secret_name).presence || followed.name
    self.image = image_or_placeholder(follower.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, follower: link_if_not_deleted(follower, :secret_name), followed: link_if_not_deleted(followed, :secret_name, :name)).html_safe
  end
  alias user_followed_transactable user_followed_user
  alias user_followed_topic user_followed_user

  def user_created_transactable
    transactable = @event.event_source
    self.image = image_or_placeholder(transactable.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(transactable.creator, :secret_name), transactable: link_if_not_deleted(transactable, :name)).html_safe
  end

  def topic_created
    topic = @event.event_source
    self.image = image_or_placeholder(topic.image)
    self.text = I18n.t(@event.i18n_key, topic: link_if_not_deleted(topic, :name)).html_safe
  end

  def user_added_photos_to_transactable
    transactable = @event.followed
    user_record = if @event.event_source.try(:creator).present?
                    @event.event_source.creator
                  else
                    transactable.creator
                  end
    user = link_if_not_deleted(user_record, :secret_name)
    self.image = image_or_placeholder(user_record.avatar)
    self.text = I18n.t(@event.i18n_key, user: user, transactable: link_if_not_deleted(transactable, :name)).html_safe
  end
  alias user_added_links_to_transactable user_added_photos_to_transactable

  def user_commented
    comment = @event.event_source
    self.image = image_or_placeholder(comment.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(comment.creator, :secret_name), followed: link_if_not_deleted(@event.followed, :secret_name, :name), activity: @event.event_source.commentable.model_name.human.downcase).html_safe
  end

  def user_commented_on_transactable
    comment = @event.event_source
    user = link_if_not_deleted(comment.creator, :secret_name)
    transactable = link_if_not_deleted(comment.commentable, :name)

    self.image = image_or_placeholder(comment.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: user, transactable: transactable).html_safe
  end

  def user_commented_on_user_activity
    comment = @event.event_source
    user = link_if_not_deleted(comment.creator, :secret_name)
    followed = link_if_not_deleted(@event.followed, :secret_name, :name)
    type = link_if_not_deleted(comment.commentable.event_source.updateable, :name)

    self.image = image_or_placeholder(comment.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: user, followed: followed, type: type).html_safe
  end

  def user_created_group
    group = @event.event_source
    self.image = image_or_placeholder(group.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(group.creator, :secret_name), group: link_if_not_deleted(group, :name)).html_safe
  end

  def user_added_photos_to_group
    group = @event.followed
    user_record = if @event.event_source.try(:creator).present?
                    @event.event_source.creator
                  else
                    group.creator
                  end
    user = link_if_not_deleted(user_record, :secret_name)
    self.image = image_or_placeholder(user_record.avatar)
    self.text = I18n.t(@event.i18n_key, user: user, group: link_if_not_deleted(group, :name)).html_safe
  end

  def user_added_links_to_group
    group = @event.followed
    user_record = if @event.event_source.try(:creator).present?
                    @event.event_source.creator
                  else
                    group.creator
                  end
    user = link_if_not_deleted(user_record, :secret_name)
    self.image = image_or_placeholder(user_record.avatar)
    self.text = I18n.t(@event.i18n_key, user: user, group: link_if_not_deleted(group, :name)).html_safe
  end

  def user_updated_group_status
    user = @event.event_source.user
    group = @event.event_source.updateable
    self.image = image_or_placeholder(user.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(user, :secret_name), group: link_if_not_deleted(group, :name)).html_safe
  end

  private

  def link_if_not_deleted(record, method_name_attempt, second_method_name_attempt = nil)
    text = record.try(method_name_attempt).presence || record.send(second_method_name_attempt)
    if record.deleted?
      text
    else
      link_to_activity_feed_object(text, record, target: @target)
    end
  end

  def image_or_placeholder(image)
    image.present? ? image : space_listing_placeholder_path(width: 80, height: 80)
  end
end
