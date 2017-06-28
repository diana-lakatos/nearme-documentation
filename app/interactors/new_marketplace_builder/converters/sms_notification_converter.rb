# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class SmsNotificationConverter < BaseConverter
      primary_key :name
      properties :name, :to, :content, :delay, :enabled, :trigger_condition

      def scope
        @model.sms_notifications
      end
    end
  end
end
