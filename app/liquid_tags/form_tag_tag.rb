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
      fail SyntaxError.new('Invalid syntax for Form Tag tag - must pass url')
    end
  end

  def render(context)
    @attributes = normalize_liquid_tag_attributes(@attributes, context)
    fail SyntaxError.new('Invalid syntax for Form Tag tag - must pass url') if @attributes[:url].blank?
    context.stack do
      context.registers[:action_view].form_tag(@attributes[:url], @attributes) do |f|
        context['form_tag_object'.freeze] = f
        render_all(@nodelist, context).html_safe
      end
    end
  end
end
