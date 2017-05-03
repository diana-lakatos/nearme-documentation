# frozen_string_literal: true
class AttachmentInput < SimpleForm::Inputs::FileInput
  def input(wrapper_options = nil)
    accept_types = options[:accept] || Rails.application.config.attachment_upload_file_types

    input_html_options[:accept] = accept_types.map { |ext| ".#{ext}" }.join(',')
    input_html_options['data-attachment-input'] = true
    input_html_options['data-object-name'] = object_name
    input_html_options['data-upload-url'] = options[:upload_url] if options[:upload_url].present?
    input_html_options['data-upload-name'] = options[:upload_name] || "#{object_name}[attachments_attributes][0][data]"
    input_html_options['multiple'] = 'multiple' if options[:multiple].present?
    input_html_options['data-model-name'] = reflection_or_attribute_name

    out = ActiveSupport::SafeBuffer.new

    field = template.content_tag :label, class: 'file-upload' do
      add_label = input_html_options['multiple'].present? ? I18n.t('attachment_upload.add_file') : I18n.t('attachment_upload.upload_file')

      upload_out = ActiveSupport::SafeBuffer.new
      upload_out << template.content_tag(:span, add_label, class: 'add-label')
      upload_out << super(wrapper_options)
    end

    out << field
    out << build_collection(Array(options[:collection]).reject(&:blank?) || [])

    template.content_tag :div, out, class: 'form-attachments'
  end

  private

  def build_collection(collection)
    collection_data = {
      'attachment-collection': true
    }

    collection_data[:sortable] = true if options[:sortable].present?

    items = ActiveSupport::SafeBuffer.new
    collection.each do |attachment|
      items << template.render(options[:attachment_template], options.merge(attachment: attachment))
    end
    template.content_tag(:ul, items, data: collection_data, class: (options[:multiple].present? ? 'multiple' : nil))
  end
end
