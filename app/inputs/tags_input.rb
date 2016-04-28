class TagsInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:"value"] = object.tags_as_comma_string
    super
  end

  def input_html_classes
    super.push('selectize-tags')
  end

end
