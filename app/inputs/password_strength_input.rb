# frozen_string_literal: true
class PasswordStrengthInput < SimpleForm::Inputs::PasswordInput
  def input(wrapper_options)
    template.content_tag :div, class: 'input-group' do
      super +
        template.content_tag(:span, class: 'input-group-addon') do
          template.content_tag('button', t('form.inputs.toggle_password'), type: 'button', class: 'btn toggle-password', 'data-toggle-password': '')
        end
    end
  end
end
