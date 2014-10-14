module CustomAttributes
  class CustomAttribute::FormElementDecorator::TimeAttr < CustomAttribute::FormElementDecorator::Base

    def options
      {
        as: :time
      }
    end

  end
end
