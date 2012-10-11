# A template which assigns a set of standard AvailabilityRules to a target.
class AvailabilityRule::Template
  attr_reader :id, :name, :days, :hours

  def initialize(options)
    @id      = options[:id]
    @name    = options[:name]
    @days    = options[:days]
    @hours   = options[:hours]
  end

  def apply(target)
    # Flag existing availability rules for destruction
    target.availability_rules.each(&:mark_for_destruction)

    @days.each do |day|
      target.availability_rules.build(
        :day => day,
        :open_hour => @hours.begin,
        :open_minute => 0,
        :close_hour => @hours.end,
        :close_minute => 0
      )
    end
  end
end
