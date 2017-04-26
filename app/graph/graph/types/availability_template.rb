# frozen_string_literal: true
module Graph
  module Types
    AvailabilityTemplate = GraphQL::ObjectType.define do
      name 'AvailabilityTemplate'

      global_id_field :id

      field :id, !types.Int
      field :availability_rules, types[Types::AvailabilityTemplates::AvailabilityRule]
      field :schedule_exception_rules, types[Types::AvailabilityTemplates::ScheduleExceptionRule] do
        resolve ->(availability_template, arg, _) do
          availability_template.schedule_exception_rules.select do |schedule_exception_rule|
            duration_range_end = schedule_exception_rule.duration_range_end
            duration_range_end ||= duration_range_end.to_time(:local) if duration_range_end.is_a?(String)
            duration_range_end > Time.zone.now
          end
        end
      end
    end
  end
end
