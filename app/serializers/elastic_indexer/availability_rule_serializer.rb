# frozen_string_literal: true
module ElasticIndexer
  class AvailabilityRuleSerializer < BaseSerializer
    attributes :open_hour,
               :open_minute,
               :close_hour,
               :close_minute,
               :days
  end
end
