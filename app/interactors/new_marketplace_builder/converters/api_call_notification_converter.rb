# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class ApiCallNotificationConverter < BaseConverter
      primary_key :name
      properties :name, :to, :content, :delay, :enabled, :trigger_condition,
                 :request_type, :headers, :format

      def scope
        @model.api_call_notifications
      end
    end
  end
end
