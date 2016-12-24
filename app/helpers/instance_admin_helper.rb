module InstanceAdminHelper
  def support_link_to_filter(active_filter, filter)
    link = filter == 'open' ? '' : filter
    link_to filter.titleize, url_for(filter: link), class: "#{active_filter == filter ? 'active' : ''}"
  end

  def support_ticket_title(ticket, length = 60)
    truncate(mask_phone_and_email_if_necessary(ticket.recent_message.try(:message)), length: length, omission: '...').to_s
  end

  def support_ticket_title_with_link(ticket)
    [
      support_ticket_title(ticket),
      " (#{ticket.messages.count})",
      '<br />',
      link_to(ticket.open_text, instance_admin_support_ticket_path(ticket)).html_safe
    ].join.html_safe
  end

  def support_author(message)
    return '' unless message
    author = link_to_if message.user, message.full_name, message.user
    "by #{author}".html_safe
  end

  def is_active_instance_admin_nav_link(controller_name, settings)
    if settings[:controller_class].present?
      'active' if settings[:controller_class] == controller.class.to_s
    else
      'active' if controller.controller_name == (settings[:controller] || controller_name).split('/').last
    end
  end

  def instance_admin_ico_for_flash(key)
    case key.to_s
    when 'notice'
      'ai-notice'
    when 'error'
      'ai-error'
    when 'success'
      'ai-success'
    when 'warning'
      'fa fa-exclamation-triangle'
    when 'deleted'
      'fa fa-trash-o'
    end
  end

  def pretty_path(path)
    path.gsub('/', ' > ').titleize
  end

  def currency_name(iso_code)
    currency = Money::Currency.find(iso_code)
    currency.nil? ? nil : "#{iso_code} - #{currency.name}"
  end

  def redirect_codes
    Domain::REDIRECT_CODES.map do |code|
      label = case code
              when 301
                'Moved permanently (301)'
              when 302
                'Temporary (302)'
              else
                code
              end

      [label, code]
    end
  end

  def next_payment_transfers_date
    l(PaymentTransfers::SchedulerMethods.new(platform_context.instance).next_payment_transfers_date.beginning_of_day, format: :long)
  end

  def wish_lists_icon_sets
    [%w(Heart heart), ['Thumbs Up', 'thumbs_up'], %w(Tick tick)]
  end

  def wish_lists_icon_set_image(set_name)
    image_tag "instance_admin/wish_lists/#{set_name}_set.png"
  end

  def languages
    I18nData.languages.map do |lang|
      translated_name = I18nData.languages(lang[0])[lang[0]].mb_chars.capitalize rescue lang[1].capitalize
      [lang[1].capitalize, lang[0].downcase, { 'data-translated' => translated_name }]
    end
  end

  def default_translation_for_key(key)
    Translation.where('instance_id is null AND key = ?', key).first.try(:value)
  end

  def authentication_provider_label(provider, type)
    case provider.downcase
    when 'facebook'
      if type == :key
        'Facebook App ID'
      else
        'Facebook App Secret'
      end
    else
      "#{provider} Consumer #{type.to_s.capitalize}"
    end
  end

  def photo_uploaders_with_versions(uploader_list)
    uploaders = {}
    uploader_list.each do |uploader|
      uploaders[uploader] = []
      uploader.constantize.dimensions.each_pair do |key, value|
        uploaders[uploader] << ["#{key} (#{value[:width]}x#{value[:height]})", key]
      end
    end
    uploaders
  end
end
