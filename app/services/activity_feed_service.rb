class ActivityFeedService
  attr_accessor :next_page

  def initialize(object, options = {})
    @object = object
    @options = options
  end

  def events(params = {})
    @page = params[:page].present? ? params[:page].to_i : 1
    per = ActivityFeedService::Helpers::EVENTS_PER_PAGE

    if @options[:user_feed].blank?
      followed_identifiers = ActivityFeedSubscription.where(follower: @object).pluck(:followed_identifier)
      itself_identifier = ActivityFeedService::Helpers.object_identifier_for(@object)
      followed_identifiers.push(itself_identifier)

      sql_array = "{#{followed_identifiers.join(',')}}"
      @events = ActivityFeedEvent
                  .with_identifiers(sql_array)
                  .includes(:event_source, :followed)
                  .exclude_events
                  .paginate(page: @page, per_page: per)
    else
      followed_identifiers = [ActivityFeedService::Helpers.object_identifier_for(@object)]
      excluded_identifiers = @object.groups.confidential.pluck(:id).map { |i| "Group_#{i}" }

      sql_include_array = "{#{followed_identifiers.join(',')}}"
      sql_exclude_array = "{#{excluded_identifiers.join(',')}}"
      @events = ActivityFeedEvent
                .with_identifiers(sql_include_array)
                .without_identifiers(sql_exclude_array)
                .includes(:event_source, :followed)
                .exclude_events
                .exclude_this_user_comments(@object)
                .paginate(page: @page, per_page: per)
    end
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
    activity_feed_event = ActivityFeedEvent.create(
      followed_id: followed.id,
      followed_type: followed.class.name,
      event_source_id: event_source.id,
      event_source_type: event_source.class.name,
      event: event,
      affected_objects: affected_objects
    )
  end
end
