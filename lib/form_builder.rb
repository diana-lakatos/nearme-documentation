# frozen_string_literal: true
class FormBuilder
  def initialize(configuration:, base_form:, object:)
    @configuration = configuration
    @base_form = base_form
    @object = object
  end

  def build
    @base_form.decorate(@configuration).new(@object)
  end
end
