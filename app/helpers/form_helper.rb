module FormHelper

  def required_field(label_text = '')
    ("<abbr title='required'>*</abbr>" + label_text).html_safe
  end

  def cke_attrs(model, field)
    return {} unless enable_ckeditor_for_field?(model, field)
    { as: :ckeditor, input_html: {ckeditor: { toolbar: ckeditor_toolbar_creator.toolbar }}}
  end

end
