module CustomAttributes
  class CustomAttribute::FormElementDecorator::Select < CustomAttribute::FormElementDecorator::Base

    def options
      {
        collection: @attribute_decorator.valid_values_translated
      }
    end

  end
end
