module FileuploadHelper
  include FormHelper

  def file_upload_input(url, name, text='Photos', options = {}, &block)
    render(partial: 'shared/components/file_upload_input', locals: {
      uploaded_content: get_uploaded_content(options, &block),
      error_message: options.delete(:error),
      multiple: options["no-multiple"] ? false : true,
      url: url,
      name: name,
      text: text
    }).to_s
  end

  def file_upload_input_with_label(label, url, name, text='Photos', options = {}, &block)
    label = required_field + label if options.delete(:required)
    content_tag(:div, 
      "<label class='text optional control-label' for='#{name}'>#{label}</label>".html_safe +
      content_tag(:div, file_upload_input(url, name, text, options, &block), :class => 'controls'), 
    :class => "control-group text optional control-fileupload")
  end

  def fileupload_photo(photo_url, destroy_photo_path, html_tag = :li)
    get_fileupload_photo_html(photo_url, destroy_photo_path, html_tag)
  end

  def get_fileupload_photo_html(photo_url, destroy_photo_path, html_tag = :li, options = {}, &block)
    id = options[:id] ? "photo-#{options[:id]}" : ''
    index = options[:index] ? options[:index] + 1 : ''
    content = capture(&block).html_safe if block_given?
    content_tag(html_tag,
      image_tag(photo_url) + 
      link_to('Delete', '' , {"data-url" => destroy_photo_path, :class => 'badge badge-inverse delete-photo delete-photo-thumb'}) +
      content_tag(:span, index, :class=> 'badge badge-inverse photo-position') +
      content,
    :class => 'photo-item', id: id)
  end
  

  private

  def get_uploaded_content(options, &block)
    if block_given?
      if options["no-multiple"]
        capture(&block)
      else
        content_tag(:div, capture(&block), id: 'sortable-photos', 'data-url' => options[:update_url])
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
