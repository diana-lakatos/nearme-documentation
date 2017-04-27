# frozen_string_literal: true
# Usage example:
# ```
# {% form_tag url: '/users' %}
# <input type="text" name="custom_field" value="" />
# <input type="submit" value="Submit" />
# {% endform_tag %}
# ```
#
# Used to generate a generic form (not one for a passed in 'object' like form_for does).
# The url where the form will post its values needs to be provided.
class FormTagTag < Liquid::Block
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError, 'Invalid syntax for Form Tag tag - must pass url'
    end
  end

  def render(context)
    attributes_with_values = normalize_liquid_tag_attributes(@attributes, context)
    raise SyntaxError, 'Invalid syntax for Form Tag tag - must pass url' if attributes_with_values[:url].blank?
    context.stack do
      context.registers[:action_view].form_tag(attributes_with_values[:url], attributes_with_values) do |f|
        context['form_tag_object'] = f
        @body.render(context).html_safe
      end
    end
  end
end
