# frozen_string_literal: true
# Usage example:
# ```
#   {% assign variable_name = 'Some description' %}
#   {% meta_description variable_name %}
# ```
#
# Used to set the description of the page to the text contained in the variable
# given as the parameter.
class MetaDescriptionTag < Liquid::Tag
  include AttributesParserHelper

  def initialize(tag_name, description, _tokens)
    super
    @description = description
  end

  def render(context)
    context.registers[:action_view].send(:meta_description, context[@description])
    nil
  end
end
