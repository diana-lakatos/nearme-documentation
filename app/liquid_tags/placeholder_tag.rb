# frozen_string_literal: true
# Usage:
# ```
#  {% placeholder: { width: 80, height: 80 } %}
# ```
#
# Generates svg placeholder with given size.
class PlaceholderTag < Liquid::Tag
  include AttributesParserHelper

  def initialize(_tag_name, markup, _tokens)
    super
    @attributes = create_initial_hash_from_liquid_tag_markup(markup).symbolize_keys
  end

  def render(_context)
    Placeholder.new(height: @attributes[:height], width: @attributes[:width])
               .path
  end
end
