class CustomValidator < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  has_paper_trail

  belongs_to :validatable, polymorphic: true
  belongs_to :instance

  serialize :valid_values, Array
  serialize :validation_rules, JSON

  before_validation :set_field_name
  before_validation :set_validation_rules

  validates :field_name, presence: true

  attr_accessor :required, :min_length, :max_length

  scope :required, -> { where(['custom_validators.validation_rules ilike ?', '%presence%']) }

  def inclusion?
    validation_rules.keys.include?('inclusion') || valid_values.present?
  end

  %w(presence numericality).each do |type|
    define_method("#{type}?") do
      validation_rules.keys.include?(type)
    end
  end

  def set_accessors
    self.required   = begin
                        validation_rules['presence'] == {}
                      rescue
                        false
                      end
    self.min_length = begin
                        validation_rules['length']['minimum']
                      rescue
                        nil
                      end
    self.max_length = begin
                        validation_rules['length']['maximum']
                      rescue
                        nil
                      end
  end

  def length_rules
    validation_rules['length']
  end

  def max_length_rule
    length_rules['maximum']
  end

  def is_required?
    validation_rules['presence'] == {}
  end

  def valid_values=(values)
    if values.is_a? String
      self[:valid_values] = values.split(/\s*,\s*/)
    else
      super
    end
  end

  def set_field_name
    self.field_name = validatable.name if validatable_type == 'CustomAttributes::CustomAttribute' && validatable.present?
    true
  end

  def set_validation_rules
    self.instance_id ||= validatable.try(:instance_id)
    self.validation_rules ||= {}
    required == true || required.try(:to_i) == 1 ? (self.validation_rules['presence'] = {}) : self.validation_rules.delete('presence')
    if min_length.present? || max_length.present?
      self.validation_rules['length'] = {}
      min_length.present? ? self.validation_rules['length']['minimum'] = min_length.to_i : self.validation_rules['length'].delete('minimum')
      max_length.present? ? self.validation_rules['length']['maximum'] = max_length.to_i : self.validation_rules['length'].delete('maximum')
    else
      self.validation_rules.delete('length')
    end
  end
end
