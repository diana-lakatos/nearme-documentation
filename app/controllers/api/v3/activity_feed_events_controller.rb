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
        Api::PaginationLinks.links(
          url_generator: ->(params) { api_activity_feed_events_url(params) },
          total_pages: events.total_pages,
          current_page: page,
          params: {}
        )
      end

      def page
        params[:page] || 1
      end
    end
  end
end
