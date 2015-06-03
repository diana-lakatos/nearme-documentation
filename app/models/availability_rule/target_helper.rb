# Helper module for availability targets.
module AvailabilityRule::TargetHelper
  # Returns an AvailabilityRule::Summary for the targets full availability rules
  def availability
    AvailabilityRule::Summary.new(availability_rules.reject(&:marked_for_destruction?))
  end

  def availability_full_week
    availability.full_week(monday_first = true)
  end

  # Assigns and applies a given AvailabilityRule::Template
  #
  # id - The id of a Template
  def availability_template_id=(id)
    return if id.blank? || id == 'custom'

    if template = AvailabilityTemplate.where(:id => id.to_i).first
      template.apply(self)
    else
      raise ArgumentError, "Can't find AvailabilityRule::Template with id '#{id}'"
    end
  end

  # Determine whether the target availability matches one of the predefined templates and return its id
  def availability_template_id
    availability = AvailabilityRule::Summary.new(availability_rules) # Don't defer at all
    template = ServiceType.first.try(:availability_templates).try(:detect) { |template| availability.matches_template?(template) }
    template.try(:id)
  end
end


