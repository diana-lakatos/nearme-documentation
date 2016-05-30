class TaxRegion < ActiveRecord::Base

  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :country

  has_many :tax_rates

  delegate :admin_name, :name, :value, to: :default_tax_rate, allow_nil: true

  accepts_nested_attributes_for :tax_rates, :reject_if => :all_blank, :allow_destroy => true

  validates :country_id, uniqueness: true, presence: true

  def default_tax_rate
    tax_rates.where(default: true).first
  end
end

