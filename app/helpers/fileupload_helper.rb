module FileuploadHelper

  def file_upload_input(url, name, text='Photos', options = {}, &block)
    content_tag(:div, 
      content_tag(:div, 
        content_tag(:span, (block_given? ? capture(&block) : ''), :class => 'uploaded') +
        "<input class='browse-file' #{"multiple" unless options["no-multiple"]} type='file' name='#{name}#{"[]" unless options["no-multiple"]}' data-url='#{url}'>".html_safe + 
        content_tag(:span, 
          content_tag(:span, '', :class => "ico-upload-photos padding") +
          content_tag(:span, text),
        :class => "btn btn-blue btn-medium upload-photos fileinput-button"),
      :class => 'action'),
    :class => 'fileupload')
  end

  def file_upload_input_with_label(label, url, name, text='Photos', options = {}, &block)
    content_tag(:div, 
      "<label class='text optional control-label' for='#{name}'>#{label}</label>".html_safe +
      content_tag(:div, file_upload_input(url, name, text, options, &block), :class => 'controls'), 
    :class => "control-group text optional control-fileupload")
  end

  def fileupload_photo(photo_url, destroy_photo_path, html_tag = :li)
    content_tag(html_tag, 
      image_tag(photo_url) + 
      link_to(content_tag(:span, '', :class=> 'ico-trash'), '' , {"data-url" => destroy_photo_path, :class => 'delete-photo delete-photo-thumb'}),
    :class => 'photo-item')
  
  end

end
