module ClickToCallButtonHelper
  include ActionView::Helpers::TagHelper

  def build_click_to_call_button(path)
    link_tag = content_tag(:a, t('phone_calls.buttons.click_to_call'), class: 'btn btn-green', data: {modal: true, href: path})
    content_tag(:div, link_tag, class: 'click-to-call')
  end

end
