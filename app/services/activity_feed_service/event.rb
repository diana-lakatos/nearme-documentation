class ActivityFeedService::Event
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  include ListingsHelper

  def controller; ApplicationController; end

  attr_accessor :image
  attr_accessor :text

  def initialize(event, target="_self")
    begin
      @event = event
      @target = target
      self.send(event.event.to_sym)
    rescue
      self.image = nil
      self.text = nil
    end
  end

  def user_updated_user_status
    user = @event.event_source.user
    updated = user.try(:properties).try(:[], :gender).presence rescue updated = ""
    self.image = image_or_placeholder(user.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(user, :secret_name), updated: updated).html_safe
  end

  def user_updated_project_status
    user = @event.event_source.user
    updated = @event.event_source.updateable
    self.image = image_or_placeholder(user.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(user, :secret_name), updated: link_if_not_deleted(updated, :name)).html_safe
  end
  alias_method :user_updated_topic_status, :user_updated_project_status

  def user_followed_user
    follower = @event.event_source.follower
    followed = @event.followed
    followed_name = followed.try(:secret_name).presence || followed.name
    self.image = image_or_placeholder(follower.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, follower: link_if_not_deleted(follower, :secret_name), followed: link_if_not_deleted(followed, :secret_name, :name)).html_safe
  end
  alias_method :user_followed_project, :user_followed_user
  alias_method :user_followed_topic, :user_followed_user


  def user_created_project
    project = @event.event_source
    self.image = image_or_placeholder(project.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(project.creator, :secret_name), project: link_if_not_deleted(project, :name)).html_safe
  end

  def topic_created
    topic = @event.event_source
    self.image = image_or_placeholder(topic.image)
    self.text = I18n.t(@event.i18n_key, topic: link_if_not_deleted(topic, :name)).html_safe
  end

  def user_added_photos_to_project
    project = @event.followed
    user_record = @event.event_source.creator rescue project.creator
    user = link_if_not_deleted(user_record, :secret_name)
    self.image = image_or_placeholder(user_record.avatar)
    self.text = I18n.t(@event.i18n_key, user: user, project: link_if_not_deleted(project, :name)).html_safe
  end
  alias_method :user_added_links_to_project, :user_added_photos_to_project


  def user_commented
    comment = @event.event_source
    self.image = image_or_placeholder(comment.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(comment.creator, :secret_name), followed: link_if_not_deleted(@event.followed, :secret_name, :name), activity: @event.event_source.commentable.model_name.human.downcase).html_safe
  end

  def user_commented_on_project
    comment = @event.event_source
    user = link_if_not_deleted(comment.creator, :secret_name)
    project = link_if_not_deleted(comment.commentable, :name)

    self.image = image_or_placeholder(comment.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: user, project: project).html_safe
  end

  def user_created_group
    group = @event.event_source
    self.image = image_or_placeholder(group.creator.avatar.url(:medium))
    self.text = I18n.t(@event.i18n_key, user: link_if_not_deleted(group.creator, :secret_name), group: link_if_not_deleted(group, :name)).html_safe
  end

  def user_added_photos_to_group
    group = @event.followed
    user_record = @event.event_source.creator rescue group.creator
    user = link_if_not_deleted(user_record, :secret_name)
    self.image = image_or_placeholder(user_record.avatar)
    self.text = I18n.t(@event.i18n_key, user: user, group: link_if_not_deleted(group, :name)).html_safe
  end

  def user_added_links_to_group
    group = @event.followed
    user_record = @event.event_source.creator rescue group.creator
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

  def link_if_not_deleted(record, method_name_attempt, second_method_name_attempt=nil)
    text = record.try(method_name_attempt).presence || record.send(second_method_name_attempt)
    record.deleted? ? text : link_to(text, record, target: @target)
  end

  def image_or_placeholder(image)
    image.present? ? image : space_listing_placeholder_path(width: 80, height: 80)
  end
end
