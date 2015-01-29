module InstanceAdminHelper

  def support_link_to_filter(active_filter, filter)
    link = filter == 'open' ? '' : filter
    link_to filter.titleize, url_for(:filter => link), class: "#{active_filter == filter ? 'active' : ''}"
  end

  def support_ticket_title(ticket, length = 60)
    truncate(ticket.recent_message.try(:message), :length => length, :omission => '...').to_s
  end

  def support_ticket_title_with_link(ticket)
    [
      support_ticket_title(ticket),
      " (#{ticket.messages.count})",
      "<br />",
      link_to(ticket.open_text, instance_admin_manage_support_ticket_path(ticket)).html_safe
    ].join.html_safe
  end

  def support_author(message)
    return "" unless message
     author = link_to_if message.user, message.full_name, message.user
    "by #{author}".html_safe
  end

  def instance_admin_ico_for_flash(key)
    case key.to_s
    when 'notice'
      "fa fa-check"
    when 'success'
      "fa fa-check"
    when 'error'
      "fa fa-exclamation-triangle"
    when 'warning'
      "fa fa-exclamation-triangle"
    when 'deleted'
      "fa fa-times"
    end
  end

  def pretty_path(path)
    path.gsub('/',' > ').titleize
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

  def dashboard_controller_name(controller)
    t_key = "hidden_items.#{controller.gsub('/', '.').gsub('#', '.').gsub('-', '_')}"
    translation = t t_key
    return translation unless translation.include?('translation_missing')

    name = controller.split('/').map(&:capitalize).join(' > ')
    tab_name = (name.include?('#') ? name.match(/#(.+)/)[1] : '').capitalize
    tab_name = " > (tab) #{tab_name}" unless tab_name.empty?
    "#{name.gsub(/#(.+)/, '')}#{tab_name}"
  end

  def tab_badge
end
