module FileuploadHelper

  def file_upload_input(url, name, text='Photos', options = {}, &block)
    uploaded_content = get_uploaded_content(options, &block)
    content_tag(:div, 
      content_tag(:div, uploaded_content, :class => 'uploaded') +
      content_tag(:label, 
        content_tag(:span, 
          content_tag(:span, '', :class => "ico-upload-photos padding") +
          content_tag(:span, text),
        :class => "btn btn-blue btn-medium upload-photos fileinput-button") +
        "<input class='browse-file' #{"multiple" unless options["no-multiple"]} type='file' name='#{name}' data-url='#{url}'>".html_safe,
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
    get_fileupload_photo_html(photo_url, destroy_photo_path, html_tag)
  end

  def get_fileupload_photo_html(photo_url, destroy_photo_path, html_tag, content = '')
    content_tag(html_tag, 
      content.html_safe +
      image_tag(photo_url) + 
      link_to(content_tag(:span, '', :class=> 'ico-trash'), '' , {"data-url" => destroy_photo_path, :class => 'delete-photo delete-photo-thumb'}),
    :class => 'photo-item')
  end

  def fileupload_photo_with_input(photo_url, destroy_photo_path, input_value, input_name = 'uploaded_photos[]',  html_tag = :li)
    get_fileupload_photo_html(photo_url, destroy_photo_path, html_tag, "<input name='#{input_name}' value='#{input_value}' type='hidden'>")
  end
  
  

  private
  def get_uploaded_content(options, &block)
    if block_given?
      if options["no-multiple"]
        capture(&block)
      else
        content_tag(:ul, capture(&block))
      end
    else
      if options["no-multiple"]
        ''
      else
        content_tag(:ul, '')
      end
    end
  end

end
