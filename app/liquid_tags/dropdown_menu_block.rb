# frozen_string_literal: true
# Usage:
# ```
#  {% dropdown_menu { label: transactable_type.bookable_noun_plural, wrapper_class: 'links' } %}
#    <li>First element</li>
#    <li>Second element</li>
#  {% enddropdown_menu %}
# ```
#
# Generates an HTML unordered list wrapped in a container. If the items in the list don't fit
# the screen a dropdown menu is provided to choose an item.
class DropdownMenuBlock < Liquid::Block
  include AttributesParserHelper

  def initialize(tag_name, markup, tokens)
    super
    @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    @label = @attributes.delete('label')
  end

  def render(context)
    @attributes = normalize_liquid_tag_attributes(@attributes, context)
    context.registers[:action_view].send(:dropdown_menu, context[@label], @attributes) { super.html_safe }
  end
end
