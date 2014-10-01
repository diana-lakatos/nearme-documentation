module CustomAttributes
  class CustomAttribute::FormElementDecorator::DateAttr < CustomAttribute::FormElementDecorator::Base

    def options
      {
        as: :date
      }
    end

  end
end
