# frozen_string_literal: true
class ActivityFeedService
  attr_accessor :next_page

  def initialize(object, user_feed: nil, page: nil, current_user: nil)
    @object = object
    @user_feed = user_feed
    @page = page.present? ? page.to_i : 1
    @current_user = current_user
  end

  def events
    @events ||= @user_feed.blank? ? events_with_followed : events_with_user_feed
  end

  def owner_id
    @object.try(:object).try(:id).presence || @object.id
  end

  def owner_type
    @object.try(:object).try(:class).try(:name).presence || @object.class.name
  end

  def has_next_page?
    events.next_page
  end
  alias has_next_page has_next_page?

  def events_next_page
    events.next_page
  end

  def self.create_event(event, followed, affected_objects, event_source)
    transactable = affected_objects.find {|a| a.kind_of?(Transactable) }

    flags = {}
    flags[:private_transactable_feed] = transactable.id if private_transactable?(transactable)

    ActivityFeedEvent.create(
      followed_id: followed.id,
      followed_type: followed.class.name,
      event_source_id: event_source.id,
      event_source_type: event_source.class.name,
      event: event,
      affected_objects: affected_objects,
      flags: flags
    )
  end

  private

  def per_page
    ActivityFeedService::Helpers::EVENTS_PER_PAGE
  end

  def events_with_followed
    followed_identifiers = ActivityFeedSubscription.where(follower: @object).pluck(:followed_identifier)
    itself_identifier = ActivityFeedService::Helpers.object_identifier_for(@object)
    followed_identifiers.push(itself_identifier)

    sql_array = "{#{followed_identifiers.join(',')}}"
    ActivityFeedEvent
      .visible_for_user(@current_user)
      .with_identifiers(sql_array)
      .includes(:event_source, :followed)
      .exclude_events
      .paginate(page: @page, per_page: per_page)
  end

  def events_with_user_feed
    followed_identifiers = [ActivityFeedService::Helpers.object_identifier_for(@object)]
    excluded_identifiers = @object.groups.confidential.pluck(:id).map { |i| "Group_#{i}" }

    sql_include_array = "{#{followed_identifiers.join(',')}}"
    sql_exclude_array = "{#{excluded_identifiers.join(',')}}"
    ActivityFeedEvent
      .visible_for_user(@current_user)
      .with_identifiers(sql_include_array)
      .without_identifiers(sql_exclude_array)
      .includes(:event_source, :followed)
      .exclude_events
      .exclude_this_user_comments(@object)
      .paginate(page: @page, per_page: per_page)
  end

  def self.private_transactable?(transactable)
    transactable && transactable.properties.try(:visibility) == 'private'
  end
end
