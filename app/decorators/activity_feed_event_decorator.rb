class ActivityFeedEventDecorator < Draper::Decorator

  delegate_all

  def text
    i18n_event_translation_key = "activity_feed.events.#{event}"
    I18n.t(i18n_event_translation_key, followed: followed.feed_followed_name)
  end
end
