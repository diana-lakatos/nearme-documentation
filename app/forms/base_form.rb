# frozen_string_literal: true
require './lib/validators/unique_validator'

class BaseForm < Reform::Form
  class << self
    def inject_dynamic_fields(configuration, whitelisted: [])
      configuration.each do |field, options|
        next unless field_whitelisted(whitelisted, field)

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

    def field_whitelisted(whitelisted, field_name)
      whitelisted == :all || whitelisted.include?(field_name.to_sym)
    end
  end

  def to_liquid
    @form_builder_drop ||= FormDrop.new(self)
  end

  delegate :new_record?, :marked_for_destruction?, :persisted?, to: :model

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
