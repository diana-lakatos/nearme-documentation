class AvatarInput < SimpleForm::Inputs::Base

  # You have to pass the content by capturing it as a block into a var, then pass it to the +content+ option
  # It's because simple_form automatically switch to BlockInput when you give a block, there is no way to override it
  def input
    out =  template.content_tag(:div, input_options.delete(:content))
    out += "#{@builder.file_field(attribute_name)}".html_safe
    out
  end

end
