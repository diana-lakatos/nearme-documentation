# frozen_string_literal: true
class FormConfiguration < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  serialize :configuration, Hash
  serialize :prepopulation_structure, Hash

  def build(object)
    FormBuilder.new(base_form: base_form.constantize,
                    configuration: configuration,
                    object: object).build
  end

  def to_liquid
    @form_configuration_drop ||= FormConfigurationDrop.new(self)
  end
end
