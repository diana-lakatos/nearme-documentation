class DropdownMenuBlock < Liquid::Block
  include AttributesParserHelper

  def initialize(tag_name, markup, tokens)
    super
    @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    @label = @attributes.delete('label')
  end

  def render(context)
    context.registers[:action_view].send(:dropdown_menu, context[@label], @attributes) { super.html_safe }
  end
end
