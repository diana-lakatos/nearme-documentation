# frozen_string_literal: true
# Usage example:
# ```
#  {% form_for current_user, url: '/users' %}
#
#    {% input_field name, field_name: @field_name, form_name: @form_name %}
#    {% input_field avatar %}
#    {% submit Save  %}
#
#  {% endform_for %}
# ```
#
# Used to generate an input tag inside a form.
# Generates only the input tag (without labels, wrappers, hints, errors)

class InputFieldTag < Liquid::Tag
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @field_name = Regexp.last_match(1)
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError, 'Invalid syntax for Input field tag - must pass field name'
    end
  end

  def render(context)
    attributes = normalize_liquid_tag_attributes(@attributes, context)
    attributes[:prompt] = :translate if attributes[:prompt] == 'translate'
    @field_name = attributes.delete(:field_name) if attributes[:field_name].present?
    form = (context["form_object_#{attributes.fetch(:form, nil)}"] || context['form_object']).source
    # drop for form_builder defined in form_builder_to_liquid_monkeypatch.rb
    form.input_field(@field_name.to_s, attributes).html_safe
  end
end
