# frozen_string_literal: true
module ElasticIndexer
  class ScheduleExceptionRuleSerializer < BaseSerializer
    attributes :duration_range_start,
               :duration_range_end,
               :label
  end
end
