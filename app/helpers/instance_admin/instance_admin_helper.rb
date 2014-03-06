module InstanceAdmin::InstanceAdminHelper

  def support_link_to_filter(active_filter, filter)
    link = filter == 'open' ? '' : filter
    link_to_unless(active_filter == filter, filter.titleize, url_for(:filter => link))
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
end
