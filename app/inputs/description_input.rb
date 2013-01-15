class DescriptionInput < SimpleForm::Inputs::Base
  include ActionView::Helpers::TagHelper
  def input
    limit = 250
    hint = "You will get better results with a more concise description. Descriptions are limited to #{limit} characters."
    out  = "#{@builder.text_field(attribute_name, {:maxlength => limit})}".html_safe
    out << content_tag(:p, hint, :class => 'help-block')
  end
end
