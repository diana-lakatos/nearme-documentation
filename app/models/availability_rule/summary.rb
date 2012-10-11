# A summary wrapper for AvailabilityRule collections which provides an interface to the availability rules in aggregate.
class AvailabilityRule::Summary
  def initialize(rules)
    @rules = rules
  end

  # Iterate over each day in the week and yield the day of week and the availability rule (if any) for that day.
  def each_day
    (0..6).each do |day|
      yield(day, rule_for_day(day))
    end
  end

  # Return the availability rule (if any) for the given day of the week.
  def rule_for_day(day)
    @rules.detect { |rule| rule.day == day }
  end

  # Return whether or not the target is open given options
  #
  # options - The availability query
  #           :day  - The day of the week
  #           :hour - The hour of the day
  #           :minute - The minute of the day
  def open_on?(options)
    raise ArgumentError.new("Options must be a hash") unless options.is_a?(Hash)
    raise ArgumentError.new("Must provide day of week") unless options[:day].is_a?(Fixnum)
    options[:minute] ||= 0

    rule = rule_for_day(options[:day])
    rule && rule.open_at?(options[:hour], options[:minute])
  end
end

