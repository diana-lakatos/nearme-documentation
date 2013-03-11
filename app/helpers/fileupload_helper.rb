module FileuploadHelper

  def file_upload_input(url, name, text='Photos', option = {}, &block)
    content_tag(:div, 
      content_tag(:div, 
        content_tag(:span, (block_given? ? capture(&block) : ''), :class => 'uploaded') +
        "<input class='browse-file' type='file' name='#{name}' data-url='#{url}'>".html_safe + 
        content_tag(:span, 
          content_tag(:span, '', :class => "ico-upload-photos padding") +
          content_tag(:span, text),
        :class => "btn btn-blue btn-medium upload-photos fileinput-button"),
      :class => 'action') +
      content_tag(:div, 
        content_tag(:div, '', :class => 'bar'), 
      :class => 'progress-bar'),
    :class => 'fileupload')
  end

  def file_upload_input_with_label(label, url, name, text='Photos', option = {}, &block)
    content_tag(:div, 
      "<label class='text optional control-label' for='#{name}'>#{label}</label>".html_safe +
      content_tag(:div, file_upload_input(url, name, text, option = {}, &block), :class => 'controls'), 
    :class => "control-group text optional control-fileupload")
  end

end
