module CustomAttributes
  class CustomAttribute::FormElementDecorator::Input < CustomAttribute::FormElementDecorator::Base

    def options
      if ['integer', 'float', 'decimal', 'datetime', 'date'].include?(@attribute_decorator.attribute_type)
        { as: @attribute_decorator.attribute_type, html5: true }
      else
        return {} unless limit
        if limit.to_f <= 50
          { as: :limited_string }
        else
          { as: :limited_text }
        end.merge({
          limit: limit,
          input_html: { maxlength: limit }
        })
      end
    end

    def limit
      @attribute_decorator.validation_rules["length"]["maximum"]
    rescue
      nil
    end
  end
end
