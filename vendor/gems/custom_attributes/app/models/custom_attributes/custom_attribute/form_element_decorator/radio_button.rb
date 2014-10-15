module CustomAttributes
  class CustomAttribute::FormElementDecorator::RadioButto < CustomAttribute::FormElementDecorator::Base

    def options
      {
        as: :radio_buttons,
        collection: @attribute_decorator.valid_values_translated
      }
    end

  end
end
