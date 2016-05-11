class FieldsForTag < Liquid::Block
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @association_name = $1
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      raise SyntaxError.new('Invalid syntax for Fields For tag - must pass association name')
    end
  end

  def render(context)
    @attributes = normalize_liquid_tag_attributes(@attributes, context, [])
    # drop for form_builder defined in form_builder_to_liquid_monkeypatch.rb

    form_name = @attributes.delete(:form)
    @form =  (context["form_object_#{form_name}"] || context["form_object"]).source
    context.stack do
      @form.simple_fields_for(@association_name) do |f|
        context["form_object_#{@association_name}".freeze] = f
        render_all(@nodelist, context).html_safe
      end
    end
  end

end

