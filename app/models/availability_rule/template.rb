# A template which assigns a set of standard AvailabilityRules to a target.
class AvailabilityRule::Template
  attr_reader :id, :name

  def initialize(options)
    @id      = options[:id]
    @name    = options[:name]
    @options = options
  end

  def apply(target)
    # Flag existing availability rules for destruction
    target.availability_rules.each(&:mark_for_destruction)

    @options[:days].each do |day|
      target.availability_rules.build(
        :day => day,
        :open_hour => @options[:hours].begin,
        :open_minute => 0,
        :close_hour => @options[:hours].end,
        :close_minute => 0
      )
    end
  end
end
