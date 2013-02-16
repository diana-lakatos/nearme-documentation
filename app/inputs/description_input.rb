class DescriptionInput < SimpleForm::Inputs::Base
  include ActionView::Helpers::TagHelper
  def input
    limit = 250
    out  = "#{@builder.text_area(attribute_name, {:maxlength => limit, :rows => 2})}".html_safe
  end
end
