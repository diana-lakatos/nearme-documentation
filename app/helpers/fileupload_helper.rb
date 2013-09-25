module FileuploadHelper
  include FormHelper

  def file_upload_input(name, url, thumbnail_sizes, text='Photos', options = {}, &block)
    render(partial: 'shared/components/file_upload_input', locals: {
      uploaded_content: get_uploaded_content(options, &block),
      error_message: options.delete(:error),
      thumbnail_sizes: thumbnail_sizes,
      url: url,
      name: name,
      text: text
    }).to_s
  end

  def built_in_upload_input(input, &block)
    render(partial: 'shared/components/built_in_upload_input', locals: {
      uploaded_content: get_uploaded_content({ "no-multiple" => true }, &block),
      input: input,
    }).to_s
  end

  def built_in_upload_input_with_label(label, input, &block)
    content_tag(:div, 
      "<label class='text optional control-label'>#{label}</label>".html_safe +
      content_tag(:div, built_in_upload_input(input, &block), :class => 'controls'), 
    :class => "control-group text optional")
  end

  def file_upload_input_with_label(label, name, url, thumbnail_sizes, text='Photos', options = {}, &block)
    label = required_field + label if options.delete(:required)
    content_tag(:div, 
      "<label class='text optional control-label' for='#{name}'>#{label}</label>".html_safe +
      content_tag(:div, file_upload_input(name, url, thumbnail_sizes, text, options, &block), :class => 'controls'), 
    :class => "control-group text optional control-fileupload")
  end

  def fileupload_photo(photo_url, destroy_photo_path, resize_photo_path, html_tag = :li)
    get_fileupload_photo_html(photo_url, destroy_photo_path, resize_photo_path, html_tag)
  end

  def built_in_fileupload_photo(photo_url, destroy_photo_path, dimensions = [96, 96])
    if photo_url
      content_tag(:div, image_tag(photo_url, :width => dimensions[0], :height => dimensions[1]) + delete_photo_link(destroy_photo_path), :class => 'photo-item')
    end
  end

  def get_fileupload_photo_html(photo_url, destroy_photo_path, resize_photo_path, html_tag = :li, options = {}, &block)
    id = options[:id] ? "photo-#{options[:id]}" : ''
    index = options[:index] ? options[:index] + 1 : ''
    content = capture(&block).html_safe if block_given?
    content_tag(html_tag,
      image_tag(photo_url) +
      delete_photo_link(destroy_photo_path) +
      resize_photo_link(resize_photo_path, id) +
      content_tag(:span, index, :class=> 'badge badge-inverse photo-position') +
      content,
    :class => 'photo-item', id: id)
  end
  

  private

  def delete_photo_link(destroy_photo_path)
    link_to('Delete', '' , {"data-url" => destroy_photo_path, :class => 'badge delete-photo delete-photo-thumb photo-action'})
  end

  def resize_photo_link(resize_photo_path, id)
    link_to('Rotate & Crop', resize_photo_path, { data: {id: id}, :rel => 'modal', :class => 'badge resize-photo photo-action'})
  end

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
