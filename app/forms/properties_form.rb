# frozen_string_literal: true
class PropertiesForm < BaseForm
  class << self
    # method implementation taken directly from reform-rails gem
    # bundle open reform-rails and check
    # lib/reform/form/active_model/model_reflections.rb
    # Alternative would be to include Reform::Form::ActiveModel::ModelReflections
    # like we do in other models, but then we would implement bunch of other methods
    def validators_on(*args)
      validation_groups.collect { |_k, group| group.instance_variable_get(:@validations).validators_on(*args) }.flatten
    end

    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          property :"#{field}"
          validates :"#{field}", options[:validation] if options[:validation].present?

          # tmp hack before we get coercion to work properly... :|
          # the reason is that for example checkbox boolean custom attributes
          # are being assigned '0' which does not trigger validation error
          # Proper handling is using `acceptance` validation instead of presence
          # Another scenario is having array (checkbox list) custom attribute - form sends
          # one blank element which prevents validation error from being displayed
          define_method("#{field}=") do |value|
            value = value.reject(&:blank?) if value.is_a?(Array)
            old_value = model.send(field)
            model.send("#{field}=", value)
            super(model.send(field))
            model.send("#{field}=", old_value)
          end
        end
      end
    end
  end

  # required by simple_form - bundle open simple_form
  # and check lib/simple_form/helpers/validators.rb
  def has_validators?
    true
  end
end
