# Usage example:
# ```
#   {% assign variable_name = 'Some Title' %}
#   {% title variable_name %}
# ```
#
# Used to set the title of the page to the text contained in the variable
# given as the parameter.
class TitleTag < Liquid::Tag
  include AttributesParserHelper

  def initialize(tag_name, title, tokens)
    super
    @title = title
  end

  def render(context)
    context.registers[:action_view].send(:title, context[@title])
    nil
  end
end
