class CancellationPolicyCondition < ActiveRecord::Base
  scoped_to_platform_context
  has_paper_trail
  acts_as_paranoid

  belongs_to :instance
  belongs_to :cancellation_policy

  validates :validators, presence: true
  validates :query, presence: true
  validate :condition_check, on: :create

  serialize :variables, Array
  serialize :validators, Array

  def translated_name
    I18n.t('activerecord.attributes.cancellation_policy_condition.name.' + name)
  end

  def liquid_variables
    variables.join('')
  end

  def liquid_condition
    "{% if #{query} %}true{% endif %}"
  end

  # private
  def condition_check
    errors.add(:query, :is_invalid) unless validators.all? {|v| check_validator(v) }
  end

  def check_validator(validator)
    validator_object = ValidatorDrop.new(validator)
    Liquid::Template.parse(liquid_variables + liquid_condition, error_mode: :strict).render(validator[:name] => validator_object) == validator[:result]
  end

  class ValidatorDrop < OrderDrop
    def initialize(validator)
      @order = OpenStruct.new(validator[:attributes])
    end
  end
end
