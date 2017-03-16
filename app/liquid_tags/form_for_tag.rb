# frozen_string_literal: true
# Usage example:
# ```
#  {% form_for current_user, url: '/users' %}
#    <input type="text" name="!{{ form_object.object_name }}_email" value="!{{ form_object.object.email }}">
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
# Used to generate a form for an object (in the example above, a user). Inside the tag, the object
# is available as "form_object".
class FormForTag < Liquid::Block
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @model_name = Regexp.last_match(1)
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError, 'Invalid syntax for Form For tag - must pass object'
    end
  end

  def render(context)
    @model = context[@model_name]
    @attributes = normalize_liquid_tag_attributes(@attributes, context, %w(html wrapper_mappings))
    @attributes.merge!(form_options) if @attributes[:form_for_type].present?
    namespace = @model.try(:source) || @model_name.to_sym

    raise 'Object passed to form_for tag cannot be nil' if namespace.blank?
    context.stack do
      context.registers[:action_view].simple_form_for(namespace, @attributes) do |f|
        context['form_object'] = f
        @body.render(context).html_safe
      end
    end
  end

  private

  def form_options
    case @attributes[:form_for_type]
    when 'dashboard'
      dashboard_form_options
    else
      raise NotImplementedError, "Valid form_for_type options are: 'dashboard', but #{@attributes[:form_for_type]} was given. Typo?"
    end
  end

  def dashboard_form_options
    options = {}

    options[:wrapper] = :dashboard_form
    options[:error_class] = :field_with_errors
    options[:wrapper_mappings] = {
      check_boxes: :dashboard_radio_and_checkboxes,
      radio_buttons: :dashboard_radio_and_checkboxes,
      file: :dashboard_file_input,
      boolean: :dashboard_boolean,
      switch: :dashboard_switch,
      inline_form: :dashboard_inline_form,
      limited_string: :dashboard_form,
      limited_text: :dashboard_form,
      tel: :dashboard_addon,
      price: :dashboard_form
    }

    options
  end
end
