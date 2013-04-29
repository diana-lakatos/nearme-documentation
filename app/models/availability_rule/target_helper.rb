# Helper module for availability targets.
module AvailabilityRule::TargetHelper
  # Returns an AvailabilityRule::Summary for the targets full availability rules
  def availability
    AvailabilityRule::Summary.new(availability_rules.reject(&:marked_for_destruction?))
  end

  def availability_full_week
    availability.full_week(monday_firt = true)
  end

  # Assigns and applies a given AvailabilityRule::Template
  #
  # id - The id of a Template
  def availability_template_id=(id)
    return if id.blank? || id == 'custom'

    if template = AvailabilityRule.templates.find { |t| t.id == id }
      template.apply(self)
    else
      raise ArgumentError, "Can't find AvailabilityRule::Template with id '#{id}'"
    end
  end

  # Determine whether the target availability matches one of the predefined templates and return its id
  def availability_template_id
    availability = AvailabilityRule::Summary.new(availability_rules) # Don't defer at all
    template = AvailabilityRule.templates.detect { |template| availability.matches_template?(template) }
    template.id if template
  end
end


