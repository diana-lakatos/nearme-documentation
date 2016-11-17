# frozen_string_literal: true
# Usage example:
# ```
#  {% form_for current_user, url: '/users' %}
#
#    {% input first_name, hint: 'this is a hint', label: 'this is a label', required: false  %}
#    {% input last_name, required: false  %}
#
#    {% input avatar %}
#    {% submit Save  %}
#
#  {% endform_for %}
# ```
#
# Used to generate an input tag inside a form. Generates the entire HTML structure for an input, its
# label, hint, required mark and their associated containers.
class InputTag < Liquid::Tag
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
    @attributes = normalize_liquid_tag_attributes(@attributes, context, %w(label_html wrapper_html input_html))
    form_name = @attributes.delete(:form)
    @form = (context["form_object_#{form_name}"] || context['form_object']).source
    @form.input(@field_name, @attributes).html_safe
  end
end
