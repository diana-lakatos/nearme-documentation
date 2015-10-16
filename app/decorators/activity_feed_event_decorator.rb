class ActivityFeedEventDecorator < Draper::Decorator
  delegate_all

  def text
    i18n_event_translation_key = "activity_feed.events.#{event}"
    followed_text = followed.try(:name).presence || followed.try(:title).presence || followed.try(:id)
    I18n.t(i18n_event_translation_key, followed: followed_text)
  end
end
