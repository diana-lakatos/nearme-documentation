class SpamReport < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :spamable, polymorphic: true

  scope :grouped_by_spammable, lambda {
    joins("LEFT JOIN comments ON spam_reports.spamable_id = comments.id AND spam_reports.spamable_type = 'Comment'")
      .joins("LEFT JOIN activity_feed_events ON spam_reports.spamable_id = activity_feed_events.id AND spam_reports.spamable_type = 'ActivityFeedEvent'")
      .where('activity_feed_events.spam_ignored = ? OR comments.spam_ignored = ?', false, false)
      .uniq
      .order('spam_reports.created_at DESC')
      .group_by(&:spamable)
  }
  scope :between_interval, ->(start_date, end_date) { where('date(spam_reports.created_at) BETWEEN ? AND ?', start_date, end_date) }
end
