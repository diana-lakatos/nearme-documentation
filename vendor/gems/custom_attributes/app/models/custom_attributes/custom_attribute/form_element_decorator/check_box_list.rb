module CustomAttributes
  class CustomAttribute::FormElementDecorator::CheckBoxList < CustomAttribute::FormElementDecorator::Base

    def options
      {
        collection: @attribute_decorator.valid_values_translated,
        as: :check_boxes
      }
    end

  end
end
