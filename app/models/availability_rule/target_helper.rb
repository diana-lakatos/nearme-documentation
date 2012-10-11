# Helper module for availability targets.
module AvailabilityRule::TargetHelper
  # Returns an AvailabilityRule::Summary for the targets full availability rules
  def availability
    AvailabilityRule::Summary.new(availability_rules.reject(&:marked_for_destruction?))
  end

  # Assigns and applies a given AvailabilityRule::Template
  #
  # id - The id of a Template
  def availability_template_id=(id)
    if template = AvailabilityRule.templates.find { |t| t.id == id }
      template.apply(self)
    else
      raise ArgumentError, "Can't find AvailabilityRule::Template with id '#{id}'"
    end
  end
end


