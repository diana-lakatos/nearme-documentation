# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class EmailNotificationConverter < BaseConverter
      primary_key :name
      properties :name, :to, :content, :delay, :enabled, :trigger_condition,
                 :from, :reply_to, :cc, :bcc, :subject, :layout_path

      def scope
        @model.email_notifications
      end
    end
  end
end
