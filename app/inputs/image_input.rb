# frozen_string_literal: true
class ImageInput < SimpleForm::Inputs::FileInput
  def input(wrapper_options = nil)
    # tmp hack to greatly simplify liquid view
    if object.is_a?(BaseForm) && object.model.is_a?(CustomImage) && object.persisted?
      options[:thumb] ||= :transformed
      options[:full_url] ||= :transformed
      options[:edit_url] ||= "/dashboard/custom_images/#{object.id}/edit"
      if !object.required?(:image) && object.model.uploader_id.present?
        options[:delete_url] ||= "/api/user/custom_images/#{object.id}"
      end
    end
    input_html_options[:accept] = 'image/*'
    input_html_options[:capture] = 'capture'
    input_html_options['data-image-input'] = true
    input_html_options['data-object-name'] = object_name
    input_html_options['data-upload-url'] = options[:upload_url] if options[:upload_url].present?
    input_html_options['data-upload-name'] = options[:upload_attr_name] if options[:upload_attr_name].present?
    input_html_options['data-model-name'] = reflection_or_attribute_name
    input_html_options['data-upload-on-save-label'] = I18n.t('image_upload.upload_on_save')
    input_html_options['data-dropzone-label'] = I18n.t('image_upload.dropzone_label')
    input_html_options['data-has-captions'] = options[:has_captions] if options[:has_captions].present?
    input_html_options['data-caption-placeholder'] = I18n.t('image_upload.caption')

    collection = options[:collection] || []

    # Make sure we accept both multiple as input option and HTML attribute
    input_html_options['multiple'] = 'multiple' if options[:multiple].present?
    options[:multiple] = true if input_html_options['multiple'].present?

    out = ActiveSupport::SafeBuffer.new

    file_input =  template.content_tag(:label, class: 'file-upload') do
      add_label = I18n.t('image_upload.upload_label', count: (options[:multiple].present? ? 2 : 1))

      upload_out = ActiveSupport::SafeBuffer.new
      upload_out << template.content_tag(:span, add_label, class: 'add-label')
      upload_out << template.content_tag(:span, I18n.t('image_upload.drag_label'), class: 'drag-label')
      upload_out << super(wrapper_options)
    end

    if options[:multiple]
      out << template.content_tag(:div, file_input, class: 'input-preview')
      out << build_collection(collection)
    else
      out << template.content_tag(:div, class: 'input-preview') do
        build_single_preview + file_input
      end
    end

    template.content_tag :div, out, class: 'form-images'
  end

  private

  def build_collection(collection)
    collection_data = {
      'image-collection': true
    }

    collection_data[:sortable] = true if options[:sortable].present?

    items = ActiveSupport::SafeBuffer.new
    collection.each do |item|
      items << build_gallery_item(item)
    end
    template.content_tag(:ul, items, data: collection_data, class: 'form-images__gallery')
  end

  def build_single_preview
    image_attribute = object.try(reflection_or_attribute_name.to_sym)

    out = ActiveSupport::SafeBuffer.new

    return out unless image_attribute.present? && !image_attribute.is_a?(ActionDispatch::Http::UploadedFile)

    template.content_tag(:div, class: 'preview') do
      out << template.content_tag(:figure) do
        image = template.image_tag(options[:thumb].present? ? image_attribute.url(options[:thumb]) : image_attribute.url)
        url = options[:full_url].present? ? image_attribute.send(options[:full_url]).to_s : image_attribute.url
        template.link_to(image, url, class: 'action--preview', rel: "preview-#{reflection_or_attribute_name}")
      end

      out << image_options(options[:edit_url], options[:delete_url])
    end
  end

  def image_options(edit_url, delete_url)
    template.content_tag(:div, class: 'form-images__options') do
      actions = ActiveSupport::SafeBuffer.new

      if edit_url.present?
        actions << template.content_tag(:button, I18n.t('image_upload.edit'), type: :button, class: 'action--edit', data: { edit: true, url: edit_url })
      end

      if delete_url.present?
        actions << template.content_tag(:button, I18n.t('image_upload.remove'), type: :button, class: 'action--delete', data: { delete: true, url: delete_url, "label-confirm": I18n.t('confirmations.are_you_sure_you_want_to_delete_this_image') })
      end

      actions
    end
  end

  def build_gallery_item(image)
    template.content_tag(:li, data: { 'photo-item': true }) do
      out = ActiveSupport::SafeBuffer.new
      out << template.link_to(template.image_tag(image[:thumb_url]), image[:full_url], class: 'action--preview', rel: "preview-#{reflection_or_attribute_name}")
      out << image_options(image[:edit_url], image[:delete_url])

      image_model_name = reflection_or_attribute_name.downcase.to_s

      if image.key? :caption
        out << template.content_tag(:span, class: 'caption') do
          template.text_field_tag("#{object_name}[#{image_model_name.pluralize}_attributes][#{image[:id]}][caption]", image[:caption], placeholder: I18n.t('image_upload.caption'))
        end
      end

      out << template.hidden_field_tag("#{object_name}[#{image_model_name}_ids][]", image[:id])
      out << template.hidden_field_tag("#{object_name}[#{image_model_name.pluralize}_attributes][#{image[:id]}][id]", image[:id])
      out << template.hidden_field_tag("#{object_name}[#{image_model_name.pluralize}_attributes][#{image[:id]}][position]", image[:position], class: 'photo-position-input')

      out << template.content_tag(:span, '', class: 'sort-handle') if options[:sortable].present?

      out
    end
  end
end
