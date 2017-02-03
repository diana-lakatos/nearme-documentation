# frozen_string_literal: true
#
# This tag should be used to render pre-defined form in Marketplace Admin.
#
# Usage example:
# ```
# {% render_form 'My Signup Form' %}
# ```
class RenderFormTag < Liquid::Tag
  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, form_name, tokens)
    super
    @form_name = form_name.strip
  end

  def render(context)
    form_hash = (context['forms'][@form_name])
    raise SyntaxError, "Invalid form name passed as argument: #{@form_name}. Valid names are: #{context['forms'].keys.join(', ')}" if form_hash.nil?
    LiquidView.new(context.registers[:action_view]).render(form_hash[:configuration].liquid_body, 'form' => form_hash[:form].to_liquid, 'configuration' => form_hash[:configuration].to_liquid)
  end
end
