# frozen_string_literal: true
# Usage example:
# ```
#  {% form_for current_user, url: '/users' %}
#    {% fields_for default_profile %}
#      {% fields_for properties, form: default_profile  %}
#        {% input drivers_licence_number, form: properties %}
#      {% endfields_for %}
#    {% endfields_for %}
#    {% input avatar %}
#    {% submit Save  %}
#  {% endform_for %}
# ```
#
# Used to generate a nested form; in the example above we generate a
# drivers_licence_number input which is a field in "properties" which in turn
# is a field of the User's "default_profile".
class FieldsForTag < Liquid::Block
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @association_name = Regexp.last_match(1)
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError, 'Invalid syntax for Fields For tag - must pass association name'
    end
  end

  def render(context)
    @attributes = normalize_liquid_tag_attributes(@attributes, context, [])
    # drop for form_builder defined in form_builder_to_liquid_monkeypatch.rb
    form_name = @attributes.fetch(:form, nil)
    form = (context["form_object_#{form_name}"] || context['form_object']).source
    context.stack do
      form.simple_fields_for(@association_name) do |f|
        context["form_object_#{@association_name}"] = f
        context[@association_name.singularize.to_s] = f.object
        render_all(@nodelist, context).html_safe
      end
    end
  end
end
