# A template which assigns a set of standard AvailabilityRules to a target.
class AvailabilityTemplate < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  has_many :availability_rules, :as => :target, :inverse_of => :target, :dependent => :destroy
  belongs_to :transactable_type
  belongs_to :instance
  has_many :transactables
  belongs_to :parent, polymorphic: true, touch: true

  # attr_accessible :transactable_type, :name, :description, :availability_rules, :availability_rules_attributes

  accepts_nested_attributes_for :availability_rules, allow_destroy: true

  # AR can't handle parent: [different_objects] condition.
  scope :for_parents, -> (parents) {
    parents.compact!
    types = parents.group_by(&:class)
    if types.one?
      where(parent: parents)
    else
      conditions = []
      types.each_pair do |type, objects|
        conditions << send(:sanitize_sql_array, ["(parent_id in (?) AND parent_type = ?)", objects, type])
      end
      where(conditions.join(' OR '))
    end
  }

  def full_name
    "#{name} (#{description})"
  end

  def minimum_booking_hours
    parent.respond_to?(:minimum_booking_minutes) || 1
  end

  def availability
    AvailabilityRule::Summary.new(availability_rules)
  end

  def custom_for_transactable?
    parent_type == 'Transactable'
  end

end
