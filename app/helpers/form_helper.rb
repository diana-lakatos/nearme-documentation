module FormHelper

  def required_field(label_text = '')
    ("<abbr title='required'>*</abbr>" + label_text).html_safe
  end

end
