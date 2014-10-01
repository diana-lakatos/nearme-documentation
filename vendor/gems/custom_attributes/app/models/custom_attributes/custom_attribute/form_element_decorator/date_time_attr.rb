module CustomAttributes
  class CustomAttribute::FormElementDecorator::DateTimeAttr < CustomAttribute::FormElementDecorator::Base

    def options
      {
        as: :datetime
      }
    end

  end
end
