# frozen_string_literal: true
#
# This tag should be used to render pre-defined form in Marketplace Admin.
#
# Usage example:
# ```
# {% render_form 'My Signup Form' %}
# ```
class RenderFormTag < Liquid::Tag
  include AttributesParserHelper
  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @form_name = Regexp.last_match(1).strip
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError, 'Invalid syntax for Render Form tag - must pass form name'
    end
  end

  def render(context)
    form_hash = (context['forms'][@form_name])
    raise SyntaxError, "Invalid form name passed as argument: #{@form_name}. Valid names are: #{context['forms'].keys.join(', ')}" if form_hash.nil?
    form = form_hash[:form] || form_hash[:configuration].build(FormConfiguration::FormObjectFactory.object(normalize_liquid_tag_attributes(@attributes, context))).tap(&:prepopulate!)
    LiquidView.new(context.registers[:action_view]).render(form_hash[:configuration].liquid_body, 'form' => form.to_liquid, 'form_configuration' => form_hash[:configuration].to_liquid)
  end
end
