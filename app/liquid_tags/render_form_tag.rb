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
    form_configuration = FormConfiguration.find_by(name: @form_name)
    raise SyntaxError, error_message if form_configuration.nil?
    # this instance variable is set in RenderCustomPage interactor
    # it's used to re-render form submitted by user in case of validation errors
    form = context['forms']&.dig(@form_name, :form)
    form ||= form_configuration.build(FormConfiguration::FormObjectFactory.object(normalize_liquid_tag_attributes(@attributes, context))).tap(&:prepopulate!)
    LiquidView.new(context.registers[:action_view]).render(form_configuration.liquid_body, 'form' => form, 'form_configuration' => form_configuration)
  end

  protected

  def error_message
    "Invalid form name passed as argument: #{@form_name}. Valid names are: #{FormConfiguration.pluck(:name)}"
  end
end
