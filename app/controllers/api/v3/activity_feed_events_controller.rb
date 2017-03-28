# frozen_string_literal: true
module Api
  module V3
    class ActivityFeedEventsController < BaseController
      skip_before_action :require_authentication

      def index
        events = ActivityFeedEvent.all.order(:created_at)
        render json: ApiSerializer.serialize_collection(events, namespace: ::V3)
      end
    end
  end
end
