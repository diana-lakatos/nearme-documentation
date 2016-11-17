# frozen_string_literal: true
# Usage example:
#
# Use this in a liquid view first:
# ```
#   {% content_for 'content_for_name' %}Hello world{% endcontent_for %}
# ```
#
# Then you can use yield inside the layout (for example) or another subsequently
# rendered view, like below:
# ```
#   {{ yield 'content_for_name' }}
# ```
class YieldTag < Liquid::Tag
  def initialize(tag_name, content_for_symbol, tokens)
    super
    @content_for_symbol = content_for_symbol.strip.gsub(/\A'|'\Z/, '').to_sym
  end

  def render(context)
    context.registers[:action_view].send(:content_for, @content_for_symbol)
  end
end
