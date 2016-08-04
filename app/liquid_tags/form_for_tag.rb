class FormForTag < Liquid::Block
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @model_name = $1
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError.new('Invalid syntax for Form For tag - must pass object')
    end
  end

  def render(context)
    @model = context[@model_name]
    @attributes = normalize_liquid_tag_attributes(@attributes, context, ['html', 'wrapper_mappings'])
    @attributes.merge!(form_options) if @attributes[:form_for_type].present?
    namespace = @model.try(:source) || @model_name.to_sym

    raise "Object passed to form_for tag cannot be nil" if namespace.blank?
    context.stack do
      context.registers[:action_view].simple_form_for(namespace, @attributes) do |f|
        context['form_object'.freeze] = f
        render_all(@nodelist, context).html_safe
      end
    end
  end

  private

  def form_options
    case @attributes[:form_for_type]
    when 'dashboard'
      dashboard_form_options
    else
      fail NotImplementedError.new("Valid form_for_type options are: 'dashboard', but #{@attributes[:form_for_type]} was given. Typo?")
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
