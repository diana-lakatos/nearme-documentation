# frozen_string_literal: true
class PropertiesForm < BaseForm
  class << self
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
            old_value = model.send(field)
            model.send("#{field}=", value)
            super(model.send(field))
            model.send("#{field}=", old_value)
          end
        end
      end
    end
  end
end
