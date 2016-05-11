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
    @attributes = normalize_liquid_tag_attributes(@attributes, context, ['html'])
    namespace = @attributes.delete(:namespace).try(:map) { |el| ServiceType === el ? el.becomes(TransactableType) : el }
    namespace ||= @model.try(:source)
    raise "Invalid object passed to form_for tag" unless @model.present? && Liquid::Drop === @model
    context.stack do
      context.registers[:action_view].simple_form_for(namespace, @attributes) do |f|
        context['form_object'.freeze] = f
        render_all(@nodelist, context).html_safe
      end
    end
  end

end

