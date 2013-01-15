class DescriptionInput < SimpleForm::Inputs::Base
  include ActionView::Helpers::TagHelper
  def input
    limit = 250
    hint = "Short description get better result, #{limit} characters should be enough."
    out  = "#{@builder.text_field(attribute_name, {:max_length => limit})}".html_safe
    out << content_tag(:p, hint, :class => 'help-block')
  end
end
