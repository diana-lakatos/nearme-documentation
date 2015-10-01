class ActivityFeedService::Event
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  def controller; ApplicationController; end

  attr_accessor :image
  attr_accessor :text

  def initialize(event)
    @event = event
    self.send(event.event.to_sym)
  end

  def user_updated_user_status
    user = @event.event_source.user
    updated = user.try(:properties).try(:[], :gender).presence rescue updated = ""
    self.image = user.avatar
    self.text = I18n.t(@event.i18n_key, user: link_to(user.secret_name, user), updated: updated).html_safe
  end

  def user_updated_project_status
    user = @event.event_source.user
    updated = @event.event_source.updateable
    self.image = user.avatar
    self.text = I18n.t(@event.i18n_key, user: link_to(user.secret_name, user), updated: link_to(updated.name, updated)).html_safe
  end
  alias_method :user_updated_topic_status, :user_updated_project_status

  def user_followed_user
    follower = @event.event_source.follower
    followed = @event.followed
    followed_name = followed.try(:secret_name).presence || followed.name
    self.image = follower.avatar
    self.text = I18n.t(@event.i18n_key, follower: link_to(follower.secret_name, follower), followed: link_to(followed_name, followed)).html_safe
  end
  alias_method :user_followed_project, :user_followed_user
  alias_method :user_followed_topic, :user_followed_user


  def user_created_project
    project = @event.event_source
    user = project.creator.deleted? ? project.creator.secret_name : link_to(project.creator.secret_name, project.creator)
    self.image = project.creator.avatar
    self.text = I18n.t(@event.i18n_key, user: user, project: project.deleted? ? project.name : link_to(project.name, project)).html_safe
  end

  def topic_created
    topic = @event.event_source
    self.image = topic.image
    self.text = I18n.t(@event.i18n_key, topic: link_to(topic.name, topic)).html_safe
  end

  def user_added_photos_to_project
    project = @event.event_source
    user = project.try(:versions).try(:last).try(:whodunnit).presence || project.creator.secret_name
    self.image = user.try(:image)
    self.text = I18n.t(@event.i18n_key, user: user, project: link_to(project.name, project)).html_safe
  end

  def user_commented
    comment = @event.event_source
    user = link_to(comment.creator.secret_name, comment.creator)
    followed = link_to((@event.followed.try(:secret_name) || @event.followed.name), @event.followed)
    self.image = comment.creator.avatar
    self.text = I18n.t(@event.i18n_key, user: user, followed: followed, activity: @event.event_source.commentable.model_name.human.downcase).html_safe
  end
end
