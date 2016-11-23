# frozen_string_literal: true
# Usage example:
# ```
#   {% link_to_add_association_tag label, form, relation %}
# ```
#
# Renders nested fields

class LinkToAddAssociationTag < Liquid::Tag
  include AttributesParserHelper

  def initialize(tag_name, markup, tokens)
    super
    @attributes = create_initial_hash_from_liquid_tag_markup(markup)
  end

  def render(context)
    @attributes = normalize_liquid_tag_attributes(@attributes, context, %w(label_html wrapper_html input_html))

    form_name = @attributes.delete(:form)
    @form = (context["form_object_#{form_name}"] || context['form_object'] || context[form_name]).source
    context.registers[:action_view].send(:link_to_add_association,
      @attributes[:label],
      @form,
      @attributes[:asocciation],
      partial: @attributes[:partial],
      form_name: @attributes[:form_name] || @attributes[:asocciation]
    )
  end
end
