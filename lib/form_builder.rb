# frozen_string_literal: true
class FormBuilder
  attr_reader :configuration, :base_form, :prepopulation_structure, :object
  def initialize(configuration:, base_form:, object:, workflow_steps: nil)
    @configuration = configuration
    @base_form = base_form
    @object = object
    @workflow_steps = workflow_steps
  end

  def build
    form_object = base_form.decorate(@configuration).new(object)
    form_object.set_workflow_steps(@workflow_steps) if @workflow_steps.present?
    form_object
  end
end
