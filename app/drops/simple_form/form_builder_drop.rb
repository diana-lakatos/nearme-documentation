# frozen_string_literal: true
class SimpleForm::FormBuilderDrop < BaseDrop
  # @!method object_name
  #   @return [String] name of the encapsulated object
  # @!method object
  #   @return [Object] encapsulated object
  delegate :object_name, :object, to: :source

  # @example To be used within form_for, fields_for tags
  # {% fields_for properties %}
  #   {{ form_object_properties.validations }}
  # {% endfields_for %}
  # @return [Hash{String => Array<String>}]
  def validations
    FormValidations.new(form_class).to_h
  end

  # @example To be used within form_for, fields_for tags
  # {% fields_for properties %}
  #   {{ form_object_properties.required_fields }}
  # {% endfields_for %}
  # @return [Array<String>}]
  def required_fields
    FormValidations.new(form_class).required_fields
  end

  class FormValidations
    def initialize(form_class)
      @form_class = form_class
    end

    def to_h
      @form_class
        .validation_groups
        .collect do |_, group|
          group.instance_variable_get(:@validations)
               ._validators
               .transform_values { |v| v.map(&:kind).map(&:to_s) }
        end
        .reduce({}, :merge)
        .stringify_keys
    end

    def required_fields
      to_h.select { |_, v| v.include?('presence') }.keys
    end
  end

  private

  def form_class
    source.object.class
  end
end
