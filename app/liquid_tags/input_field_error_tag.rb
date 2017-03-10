# frozen_string_literal: true
# Usage example:
# ```
#  {% form_for current_user, url: '/users' %}
#
#    {% input_field name, field_name: @field_name, form_name: @form_name %}
#    {% input_field_error name %}
#    {% submit Save  %}
#
#  {% endform_for %}
# ```
#
# Used to generate an .error-block paragraph when form validation fails.

class InputFieldErrorTag < Liquid::Tag
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @field_name = Regexp.last_match(1)
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError, 'Invalid syntax for Input field error tag - must pass field name'
    end
  end

  def render(context)
    attributes = normalize_liquid_tag_attributes(@attributes, context)
    @field_name = attributes.delete(:field_name) if attributes[:field_name].present?
    @attributes['form'] = attributes.delete(:form_name) if attributes[:form_name].present?
    form = (context["form_object_#{@attributes.fetch('form', nil)}"] || context['form_object']).source
    # drop for form_builder defined in form_builder_to_liquid_monkeypatch.rb
    form.error(@field_name, attributes)&.html_safe
  end
end
