class InputTag < Liquid::Tag
  include AttributesParserHelper

  Syntax = /(#{Liquid::VariableSignature}+)\s*/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ Syntax
      @field_name = Regexp.last_match(1)
      @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    else
      fail SyntaxError.new('Invalid syntax for Input tag - must pass field name')
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
