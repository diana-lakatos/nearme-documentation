class ActivityFeedService
  attr_accessor :next_page

  def initialize(object)
    @object = object
  end

  def events(params={})
    @page = params[:page].present? ? params[:page].to_i : 1
    per = ActivityFeedService::Helpers::EVENTS_PER_PAGE

    followed_identifiers = ActivityFeedSubscription.where(followed: @object).pluck(:followed_identifier)
    itself_identifier = ActivityFeedService::Helpers.object_identifier_for(@object)
    followed_identifiers.push(itself_identifier)

    sql_array = "{#{followed_identifiers.join(',')}}"
    @events = ActivityFeedEvent.with_identifiers(sql_array).includes(:event_source, :followed).paginate(page: @page, per_page: per)
  end

  def owner_id
    @object.try(:object).try(:id).presence || @object.id
  end

  def owner_type
    @object.try(:object).try(:class).try(:name).presence || @object.class.name
  end

  def has_next_page?
    @events.next_page
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
