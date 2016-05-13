module ClickToCallPreferencesHelper
  include ActionView::Helpers::TagHelper

  def build_click_to_call_verify_button(phone, country_name)
    if current_user.communication.try(:verified?)
      link_to t('dashboard.click_to_call.verified'), edit_dashboard_click_to_call_preferences_path, class: 'btn btn-sm btn-primary', :'data-ctc-trigger' => '', :'data-verify-url' => verified_user_communications_path(current_user)
    else
      link_to t('dashboard.click_to_call.verify'), edit_dashboard_click_to_call_preferences_path, class: 'btn btn-sm btn-primary', :'data-ctc-trigger' => '', :'data-ajax-options' => { phone: phone, country_name: country_name }.to_json, :'data-verify-url' => verified_user_communications_path(current_user)
    end
  end

  def click_to_call_labels
    {
      'validation-code': t('dashboard.click_to_call.validation_code_message_html'),
      'connect-success-message': t('dashboard.click_to_call.connect_success_message_html'),
      'connect-error-message': t('dashboard.click_to_call.connect_error_message_html'),
      'disconnect-success-message': t('dashboard.click_to_call.disconnect_success_message_html'),
      'disconnect-error-message': t('dashboard.click_to_call.disconnect_error_message_html')
    }
  end
end
