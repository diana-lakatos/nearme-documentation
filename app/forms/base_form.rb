# frozen_string_literal: true
require './lib/validators/unique_validator'

class BaseForm < Reform::Form
  class << self
    def inject_dynamic_fields(configuration)
      configuration.each do |field, options|
        add_property(field, options)
        add_validation(field, options)
      end
    end

    def inject_custom_attributes(configuration)
      if (properties_configuration = configuration.delete(:properties)).present?
        add_validation(:properties, properties_configuration)
        property :properties, form: PropertiesForm.decorate(properties_configuration)
      end
    end

    def add_validation(field, options)
      return if options.nil?
      return unless options.key?(:validation)
      validation = options.delete(:validation)
      validates :"#{field}", ValidationHash.new(validation).sanitize if validation.any?
    end

    def add_property(field, options)
      property :"#{field}", options&.fetch(:property_options, {}) || {}
    end

    def reflect_on_association(*_args)
      nil
    end

    def checked?(value)
      value == '1' || value == 'true'
    end
  end

  def to_liquid
    @form_builder_drop ||= FormDrop.new(self)
  end

  def save
    if super && model.persisted? && @workflow_steps.present?
      @workflow_steps.each do |step|
        WorkflowStepJob.perform(step.associated_class.constantize, model.id, step_id: step.id)
      end
    end
  end

  def set_workflow_steps(workflow_steps)
    @workflow_steps = workflow_steps
  end

  delegate :new_record?, :marked_for_destruction?, :persisted?, to: :model

  # Ideally this method should not exist, forms should be clever enough to use translations automatically
  # Not that simple though:
  # see for example @user_update_profile_form.class.human_attribute_name(:'buyer_profile.properties.driver_category')
  # on localdriva.
  # One idea is to create translations for each custom attribute etc and then `full_messages` will be working properly.
  # In current form there will be conflicts though + we would need translations for all built in attributes as well.
  # Hence, tmp hack.
  def pretty_errors_string(separator: "\n")
    ErrorsSummary.new(self).summary(separator: separator)
  end

  def required?(attr)
    self.class.validators_on(attr).any? { |v| v.kind == :presence }
  end

  def checked?(value)
    self.class.checked?(value)
  end

  def date_time_handler
    @date_time_handler ||= ::DateTimeHandler.new
  end
end
