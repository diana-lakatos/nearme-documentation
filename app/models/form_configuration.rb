# frozen_string_literal: true
class FormConfiguration < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  serialize :configuration, Hash
  serialize :prepopulation_structure, Hash

  has_many :page_forms, dependent: :destroy
  has_many :pages, through: :page_forms

  before_save :generate_parameterized_name, if: ->(fc) { fc.name_changed? }

  def generate_parameterized_name
    self.name = name.downcase.tr(' ', '_')
  end

  def build(object)
    FormBuilder.new(base_form: base_form.constantize,
                    configuration: configuration.deep_symbolize_keys,
                    object: object).build
  end

  def to_liquid
    @form_configuration_drop ||= FormConfigurationDrop.new(self)
  end
end
