class ActivityFeedEventDecorator < Draper::Decorator
  delegate_all

  def text
    i18n_event_translation_key = "activity_feed.events.#{event}"
    followed_text = followed.try(:name).presence || followed.try(:title).presence || followed.try(:id)
    I18n.t(i18n_event_translation_key, followed: followed_text)
  end

  def is_status_update_event?
    [
      :user_updated_group_status,
      :user_updated_user_status,
      :user_updated_transactable_status
    ].include?(event.to_sym)
  end
  alias is_status_update_event is_status_update_event?

  def is_comment_event?
    [
      :user_commented_on_user_activity,
      :user_commented_on_transactable,
      :user_commented
    ].include?(event.to_sym)
  end
  alias is_comment_event is_comment_event?

  def is_photo_event?
    [
      :user_added_photos_to_transactable,
      :user_added_photos_to_group
    ].include?(event.to_sym) && event_source.is_a?(Photo)
  end
  alias is_photo_event is_photo_event?

  def header_image
    ActivityFeedHelper.header_image_for_event(model)
  end
end
