module CustomAttributes
  class CustomAttribute::FormElementDecorator::RadioButton < CustomAttribute::FormElementDecorator::Base

    def options
      {
        as: :radio_buttons,
        collection: @attribute_decorator.valid_values_translated
      }
    end

  end
end
