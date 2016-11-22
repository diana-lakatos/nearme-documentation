module CustomAttributes
  class CustomAttribute::FormElementDecorator::RangeAttr < CustomAttribute::FormElementDecorator::Base

    attr_reader :attribute_decorator
    delegate :default_value, :min_value, :max_value, :step, to: :attribute_decorator

    def options
      {
        as: :custom_range,
        input_html: {
          min: min_value,
          max: max_value,
          step: step,
          value: default_value
        }
      }
    end

  end
end

