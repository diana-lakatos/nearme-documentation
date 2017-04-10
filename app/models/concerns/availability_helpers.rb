# frozen_string_literal: true
require 'active_support/concern'

module AvailabilityHelpers
  extend ActiveSupport::Concern

  included do
    def custom_availability_template?
      availability_template&.custom_for_object?
    end

    # TODO: remove after FormConfiguration
    def availability_templates_attributes=(template_attributes)
      if template_attributes.present?
        super(template_attributes)
        self.availability_template = availability_templates.first
      end
    end

    # @return [Array<ScheduleExceptionRule>] array of schedule exception rules for future dates
    def availability_exceptions
      availability_template&.future_availability_exceptions
    end
  end
end
