# frozen_string_literal: true
module ActivityFeedHelper
  def feed_data
    return {} unless current_user
    {
      current_user_id: current_user.id,
      comments_spam_reports: current_user.spam_reports.where(spamable_type: 'Comment').pluck(:spamable_id),
      events_spam_reports: current_user.spam_reports.where(spamable_type: 'ActivityFeedEvent').pluck(:spamable_id)
    }.stringify_keys
  end

  def self.commented_own_thread?(comment)
    creator_id = if comment.commentable.is_a?(ActivityFeedEvent)
                   event = comment.commentable
                   event.event_source.try(:creator_id) || event.followed.try(:creator_id)
                 else
                   comment.commentable.try(:creator_id)
                 end
    creator_id == comment.creator_id
  end

  def commented_own_thread?(comment)
    ActivityFeedHelper.commented_own_thread?(comment)
  end

  def self.header_image_for_event(event)
    if event.event_source.is_a?(Link) && event.event_source.try(:image).try(:file).present?
      event.event_source.image.url(:medium)
    else
      followed = event.event_source.is_a?(Photo) ? event.event_source : event.followed
      image = followed.try(:cover_image).try(:url, :medium) if followed.is_a?(Group)
      image ||= (followed.try(:image).presence || followed.try(:avatar)).try(:url, :medium)
      image.present? ? image : followed.try(:cover_photo).try(:image).try(:url, :medium)
    end
  end

  def header_image_for_event(event)
    ActivityFeedHelper.header_image_for_event(event)
  end

  def status_update_event?(event_name)
    [
      :user_updated_group_status,
      :user_updated_user_status,
      :user_updated_transactable_status
    ].include?(event_name.to_sym)
  end

  def comment_event?(event_name)
    [
      :user_commented_on_user_activity,
      :user_commented_on_transactable,
      :user_commented
    ].include?(event_name.to_sym)
  end

  def followed_link(followed, target, &block)
    block_contents = capture(&block)
    if followed.is_a?(ActivityFeedEvent)
      block_contents
    else
      link_to_activity_feed_object block_contents, followed, target: target
    end
  end
end
