module ActivityFeedHelper

  def feed_data
    return {} unless current_user
    {
      current_user_id: current_user.id,
      comments_spam_reports: current_user.spam_reports.where(spamable_type: 'Comment').pluck(:spamable_id),
      events_spam_reports: current_user.spam_reports.where(spamable_type: 'ActivityFeedEvent').pluck(:spamable_id)
    }
  end

  def followed_link(followed, target, &block)
    block_contents = capture(&block)
    if followed.is_a?(ActivityFeedEvent)
      block_contents
    else
      link_to followed, target: target do
        block_contents
      end
    end
  end

end
