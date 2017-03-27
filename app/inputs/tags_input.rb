# frozen_string_literal: true
class TagsInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:value] = object.respond_to?(:tags_as_comma_string) ? object.tags_as_comma_string : Array(object.tag_list).join(',')
    super
  end

  def input_html_classes
    super.push('selectize-tags')
  end
end
