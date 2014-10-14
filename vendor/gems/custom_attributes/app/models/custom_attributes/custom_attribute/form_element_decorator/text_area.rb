module CustomAttributes
  class CustomAttribute::FormElementDecorator::TextArea < CustomAttribute::FormElementDecorator::Base

    def options
      {
        as: :text
      }
    end

  end
end
