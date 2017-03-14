# frozen_string_literal: true
# Usage example:
# ```
#   {% link_to_remove_association_tag label, form, relation %}
# ```
#
# Renders nested fields

class LinkToRemoveAssociationTag < Liquid::Tag
  include AttributesParserHelper

  def initialize(tag_name, markup, tokens)
    super
    @attributes = create_initial_hash_from_liquid_tag_markup(markup)
  end

  def render(context)
    @attributes = normalize_liquid_tag_attributes(@attributes, context, %w(label_html wrapper_html input_html))

    form_name = @attributes.fetch(:form, nil)
    form = (context["form_object_#{form_name}"] || context[form_name] || context['form_object']).source
    raise LinkToAssociation::HelpfulLinkToAssociationError.raise_form_is_nil('LinkToRemoveAssociation', form_name) if form.nil?
    raise LinkToAssociation::HelpfulLinkToAssociationError.raise_form_object_is_nil('LinkToRemoveAssociation', form_name) if form&.object.nil?
    context.registers[:action_view].send(:link_to_remove_association,
      @attributes[:label],
      form
    )
  end
end
