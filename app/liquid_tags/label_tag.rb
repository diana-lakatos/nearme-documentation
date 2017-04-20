# frozen_string_literal: true
# Usage example:
# ```
#  {% form_for current_user, url: '/users' %}
#
#    {% label first_name  %}
#    {% input_field first_name, required: false  %}
#
#    {% input avatar %}
#    {% submit Save  %}
#
#  {% endform_for %}
# ```
#
# Used to generate a label tag inside a form. Generates the entire HTML structure for a label
class LabelTag < Liquid::Tag
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @field_name = Regexp.last_match(1)
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError, 'Invalid syntax for Input tag - must pass field name'
    end
  end

  def render(context)
    # drop for form_builder defined in form_builder_to_liquid_monkeypatch.rb
    attributes = normalize_liquid_tag_attributes(@attributes, context)
    @field_name = attributes.delete(:field_name) if attributes[:field_name].present?
    form = (context["form_object_#{attributes.fetch(:form, nil)}"] || context['form_object']).source
    attributes[:prompt] = :translate if attributes[:prompt] == 'translate'
    form.label(@field_name.to_s, attributes).html_safe
  end
end
