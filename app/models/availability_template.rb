# A template which assigns a set of standard AvailabilityRules to a target.
class AvailabilityTemplate < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  has_many :availability_rules, :as => :target, :inverse_of => :target, :dependent => :destroy
  belongs_to :transactable_type, :inverse_of => :availability_templates

  attr_accessible :transactable_type, :name, :description, :availability_rules

  def full_name
    "#{name} (#{description})"
  end

  def includes_rule?(rule)
    availability_rules.find do |existing_rule|
      existing_rule.day == rule.day && existing_rule.open_hour == rule.open_hour && existing_rule.close_hour == rule.close_hour &&
        existing_rule.open_minute == rule.open_minute && existing_rule.close_minute == rule.close_minute
    end
  end

  def apply(target)
    # Flag existing availability rules for destruction
    target.availability_rules.each(&:mark_for_destruction)

    availability_rules.each do |rule|
      target.availability_rules.build(
        :day => rule.day,
        :open_hour => rule.open_hour,
        :open_minute => rule.open_minute,
        :close_hour => rule.close_hour,
        :close_minute => rule.close_minute
      )
    end
  end
end
