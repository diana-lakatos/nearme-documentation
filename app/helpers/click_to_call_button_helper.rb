module ClickToCallButtonHelper
  include ActionView::Helpers::TagHelper

  def build_click_to_call_button_for_transactable(transactable)
    return unless PlatformContext.current.instance.click_to_call? && transactable.administrator.click_to_call? && transactable.administrator.communication.try(:verified)

    path_to_call = Rails.application.routes.url_helpers.new_user_phone_call_path(transactable.administrator)

    closest_availability = transactable.first_available_date.to_datetime.in_time_zone(transactable.timezone)


    if closest_availability
      open_minute = transactable.availability.open_minute_for(closest_availability)
      closest_availability = closest_availability.change({ min: open_minute.modulo(60), hour: (open_minute / 60).floor })
    end

    build_click_to_call_button(path_to_call, I18n.t('phone_calls.buttons.click_to_call'), transactable.open_now?, transactable.timezone, closest_availability)
  end

  def build_click_to_call_button_for_user(user)
    return unless PlatformContext.current.instance.click_to_call? && user.click_to_call? && user.communication.try(:verified)

    path_to_call = Rails.application.routes.url_helpers.new_user_phone_call_path(user)
    build_click_to_call_button(path_to_call, I18n.t('phone_calls.buttons.click_to_call_user', name: user.name), user.is_available_now?, user.time_zone)
  end

  def show_not_verified_user_alert?(transactable)
    PlatformContext.current.instance.click_to_call? && transactable && transactable.administrator.communication.try(:verified) && !current_user.communication.try(:verified)
  end

  def show_not_verified_host_alert?(reservation)
    PlatformContext.current.instance.click_to_call? && reservation.listing.present? && reservation.owner.communication.try(:verified) && !current_user.communication.try(:verified)
  end

  private

    def build_click_to_call_button(path, label, available_now, timezone, next_available_occurence = nil)
      time_info = I18n.t('phone_calls.tooltip.current_time', time: I18n.l(Time.now.in_time_zone(timezone), format: :short_with_time_zone))

      available_info = next_available_occurence ? I18n.t('phone_calls.tooltip.next_available_occurence', time: I18n.l(next_available_occurence, format: :with_time_zone)) : ''

      if available_now
        tag = content_tag(:a, label, class: 'btn btn-primary btn-green', href: path, data: { modal: true, href: path, :"modal-class" => 'ctc-dialog' }, title: time_info, rel: 'tooltip', :'data-toggle' => 'tooltip')
      else
        tag = content_tag(:span, label, class: 'btn btn-primary disabled btn-gray', title: "#{time_info}#{available_info}", rel: 'tooltip', :'data-toggle' => 'tooltip')
      end
      content_tag(:span, tag, class: 'click-to-call')
    end

end
