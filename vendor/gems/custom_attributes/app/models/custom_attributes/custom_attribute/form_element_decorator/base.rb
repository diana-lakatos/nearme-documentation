module CustomAttributes
  class CustomAttribute::FormElementDecorator::Base

    attr_reader :attribute_decorator

    def initialize(attribute)
      @attribute_decorator = attribute
    end

  end
end

