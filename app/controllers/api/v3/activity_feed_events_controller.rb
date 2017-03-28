# frozen_string_literal: true
module Api
  module V3
    class ActivityFeedEventsController < BaseController
      skip_before_action :require_authentication
      PER_PAGE = 50

      def index
        events = ActivityFeedEvent.all.order(:created_at).paginate(page: page, per_page: PER_PAGE)
        render json: ApiSerializer.serialize_collection(
          events,
          namespace: ::V3,
          meta: { total_entries: events.total_entries, total_pages: events.total_pages },
          links: pagination_links(events)
        )
      end

      private

      def pagination_links(events)
        {
          first: api_activity_feed_events_url(page: 1),
          last: api_activity_feed_events_url(page: events.total_pages),
          prev: page > 1 ? api_activity_feed_events_url(page: page - 1) : nil,
          next: page < events.total_pages ? api_activity_feed_events_url(page: page + 1) : nil
        }
      end

      def page
        params[:page] || 1
      end
    end
  end
end
