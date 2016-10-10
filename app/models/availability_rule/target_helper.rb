# Helper module for availability targets.
module AvailabilityRule::TargetHelper
  # Returns an AvailabilityRule::Summary for the targets full availability rules
  def availability
    availability_template.try(:availability)
  end

  def availability_full_week
    availability.full_week(monday_first = true)
  end
end
