# frozen_string_literal: true
module ElasticIndexer
  class AvailabilityTemplateSerializer < BaseSerializer
    has_many :availability_rules, serializer: AvailabilityRuleSerializer
    has_many :schedule_exception_rules, serializer: ScheduleExceptionRuleSerializer
  end
end
