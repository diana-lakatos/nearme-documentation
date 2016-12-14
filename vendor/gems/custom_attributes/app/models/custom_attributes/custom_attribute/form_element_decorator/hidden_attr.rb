module CustomAttributes
  class CustomAttribute::FormElementDecorator::HiddenAttr < CustomAttribute::FormElementDecorator::Base

    attr_reader :attribute_decorator
    delegate :default_value, to: :attribute_decorator

    def options
      {
        as: :hidden,
        input_html: {
          value: default_value
        }
      }
    end

  end
end

