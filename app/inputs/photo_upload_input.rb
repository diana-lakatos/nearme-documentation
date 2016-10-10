class PhotoUploadInput < SimpleForm::Inputs::FileInput
  def input(wrapper_options)
    input_html_options[:accept] = 'image/*'
    input_html_options[:capture] = 'capture'

    template.content_tag :span, class: 'file-a', data: { label: 'Add photo' } do
      super(wrapper_options)
    end
  end
end
