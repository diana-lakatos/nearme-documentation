class TaxRate < ActiveRecord::Base
  CALCULATE_WITH = { add: 'Added to the default tax', replace: 'Instead of the default tax' }

  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :tax_region
  belongs_to :instance
  belongs_to :state

  scope :default, -> { where(default: true) }

  validates :state, presence: true, if: proc { |t| !t.default? }
  validates :value, presence: true, inclusion: 1..100
  validates :name, presence: true
end
