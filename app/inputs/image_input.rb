class ImageInput < SimpleForm::Inputs::FileInput
  def input(wrapper_options = nil)
    input_html_options[:accept] = "image/*"
    input_html_options[:capture] = "capture"
    input_html_options["data-image-input"] = true
    input_html_options["data-object-name"] = object_name
    input_html_options["data-upload-url"] = options[:upload_url] if options[:upload_url].present?
    input_html_options["data-upload-name"] = options[:upload_attr_name] if options[:upload_attr_name].present?
    input_html_options["multiple"] = "multiple" if options[:multiple].present?
    input_html_options["data-model-name"] = reflection_or_attribute_name

    out = ActiveSupport::SafeBuffer.new

    field = template.content_tag :label, class: 'file-upload' do
      add_label = input_html_options[:multiple].present? ? I18n.t('image_upload.add_photo') : I18n.t('image_upload.upload_photo')

      upload_out = ActiveSupport::SafeBuffer.new
      upload_out << template.content_tag(:span, add_label, class: 'add-label')
      upload_out << super(wrapper_options)
    end

    out << field

    if options[:collection].present?
      collection = options[:collection]
    else
      collection = Array.new
      image_attribute = object.try(reflection_or_attribute_name.to_sym)

      if image_attribute.present?

        input_html_options["data-model-name"] = image_attribute

        item = Hash.new
        item[:full_url] = image_attribute.url
        item[:thumb_url] = options[:thumb].present? ? image_attribute.send(options[:thumb]) : image_attribute.url
        item[:thumb_url] = options[:thumb_url] if options[:thumb_url].present?

        item[:edit_url] = options[:edit_url] if options[:edit_url].present?
        item[:delete_url] = options[:delete_url] if options[:delete_url].present?

        collection << item
      end
    end

    out << build_collection(collection)

    template.content_tag :div, out, class: 'form-photos'
  end

  private
    def build_collection(collection)
      collection_data = {
        :'image-collection' => true
      }

      if options[:sortable].present?
        collection_data[:sortable] = true
      end

      items = ActiveSupport::SafeBuffer.new
      collection.each do |item|
        items << build_preview(item)
      end
      template.content_tag(:ul, items, data: collection_data, class: (options[:multiple].present? ? 'multiple' : nil))
    end

    def build_preview(image)

      template.content_tag(:li, data: { 'photo-item': true }) do
        out = ActiveSupport::SafeBuffer.new
        out << template.link_to( template.image_tag(image[:thumb_url]), image[:full_url], class: 'action--preview', rel: "preview-#{reflection_or_attribute_name}")
        out << template.content_tag(:div, class: 'options') do
          actions = ActiveSupport::SafeBuffer.new

          if image[:edit_url].present?
            actions << template.content_tag(:button, I18n.t('image_upload.edit'), type: :button, class: 'action--edit', data: { edit: true, url: image[:edit_url] })
          end
          if image[:delete_url].present?
            actions << template.content_tag(:button, I18n.t('image_upload.remove'), type: :button, class: 'action--delete', data: { delete: true, url: image[:delete_url], "label-confirm": I18n.t('confirmations.are_you_sure_you_want_to_delete_this_image')})
          end

          actions
        end

        if options[:multiple]

          image_model_name = reflection_or_attribute_name.downcase.to_s

          out << template.hidden_field_tag("#{object_name}[#{image_model_name}_ids][]", image[:id])
          out << template.hidden_field_tag("#{object_name}[#{image_model_name.pluralize}_attributes][#{image[:id]}][id]", image[:id])
          out << template.hidden_field_tag("#{object_name}[#{image_model_name.pluralize}_attributes][#{image[:id]}][position]", image[:position], class: 'photo-position-input')
        end

        if options[:sortable].present?
          out << template.content_tag(:span, '', class: 'sort-handle')
        end

        out
      end
    end
end
