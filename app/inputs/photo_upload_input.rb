# frozen_string_literal: true
class PhotoUploadInput < SimpleForm::Inputs::FileInput
  def input(wrapper_options)
    input_html_options[:accept] = 'image/gif, image/jpeg, image/jpg, image/png'

    template.content_tag :span, class: 'file-a', data: { label: 'Add photo' } do
      super(wrapper_options)
    end
  end
end
