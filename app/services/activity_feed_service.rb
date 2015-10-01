class ActivityFeedService
  EVENTS_PER_PAGE = 20

  def initialize(object)
    @object = object
  end

  def events(params={})
    page = params[:page].to_i || 1
    per = ActivityFeedService::EVENTS_PER_PAGE
    offset = (page == 0) ? 0 : page * per - per

    followed_identifiers = ActivityFeedSubscription.where(followed: @object).pluck(:followed_identifier)
    itself_identifier = ActivityFeedService::Helpers.object_identifier_for(@object)
    followed_identifiers.push(itself_identifier)

    sql_array = "{#{followed_identifiers.join(',')}}"
    @next_page = ActivityFeedEvent.where("affected_objects_identifiers && ?", sql_array).order(created_at: :desc).uniq.count > offset + per
    ActivityFeedEvent.where("affected_objects_identifiers && ?", sql_array).order(created_at: :desc).offset(offset).limit(per).uniq
  end

  def next_page?
    @next_page
  end

  def owner_id
    @object.try(:object).try(:id).presence || @object.id
  end

  def owner_type
    @object.try(:object).try(:class).try(:name).presence || @object.class.name
  end

  def self.create_event(event, followed, affected_objects, event_source)
    activity_feed_event = ActivityFeedEvent.where(
      followed_id: followed.id,
      followed_type: followed.class.name,
      event_source_id: event_source.id,
      event_source_type: event_source.class.name,
      event: event,
    ).first_or_initialize

    if activity_feed_event.id.present?
      activity_feed_event.touch
    else
      activity_feed_event.affected_objects = affected_objects
      activity_feed_event.save
    end
  end
end
