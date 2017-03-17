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
    form_name = @attributes.fetch(:form, nil)
    form = (context["form_object_#{form_name}"] || context[form_name] || context['form_object']).source
    raise LinkToAssociation::HelpfulLinkToAssociationError.raise_form_is_nil('LinkToAddAssociation', form_name) if form.nil?
    raise LinkToAssociation::HelpfulLinkToAssociationError.raise_form_object_is_nil('LinkToAddAssociation', form_name) if form&.object.nil?
    context.registers[:action_view].send(:link_to_add_association,
                                         @attributes[:label],
                                         form,
                                         @attributes[:association],
                                         class: @attributes[:class],
                                         partial: @attributes[:partial],
                                         form_name: @attributes[:form_name] || @attributes[:association])
  end
end
