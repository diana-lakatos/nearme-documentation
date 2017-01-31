# frozen_string_literal: true
module ActivityFeedHelper
  def feed_data
    return {} unless current_user
    {
      current_user_id: current_user.id,
      comments_spam_reports: current_user.spam_reports.where(spamable_type: 'Comment').pluck(:spamable_id),
      events_spam_reports: current_user.spam_reports.where(spamable_type: 'ActivityFeedEvent').pluck(:spamable_id)
    }
  end

  def commented_own_thread?(comment)
    if comment.commentable.is_a?(ActivityFeedEvent)
      event = comment.commentable
      creator_id = event.event_source.try(:creator_id) || event.followed.try(:creator_id)
      creator_id == comment.creator_id
    else
      creator_id = comment.commentable.try(:creator_id)
      creator_id == comment.creator_id
    end
  end

  def status_update_event?(event_name)
    [
      :user_updated_group_status,
      :user_updated_user_status
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
