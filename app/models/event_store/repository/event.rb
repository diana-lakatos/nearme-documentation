# frozen_string_literal: true
module EventStore
  module Repository
    class Event < ActiveRecord::Base
      self.table_name = 'event_store_events'
      auto_set_platform_context
      scoped_to_platform_context

      belongs_to :instance
      belongs_to :triggered_by, class_name: 'User'
      serialize :payload

      validates :event_type, presence: true
    end
  end
end
