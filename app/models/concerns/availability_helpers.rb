require 'active_support/concern'

module AvailabilityHelpers
  extend ActiveSupport::Concern

  included do

    def custom_availability_template?
      availability_template&.custom_for_object?
    end

    def availability_template_attributes=(template_attributes)
      if template_attributes.present?
        if template_attributes['id'].present?
          self.availability_template_id = template_attributes['id']
          availability_template.assign_attributes template_attributes
        else
          template_attributes[:name] = 'Custom transactable availability'
          template_attributes[:parent] = self
          self.availability_template = AvailabilityTemplate.new(template_attributes)
        end
      end
    end

    # @return [Array<ScheduleExceptionRule>] array of schedule exception rules for future dates
    def availability_exceptions
      availability_template&.future_availability_exceptions
    end

  end

end