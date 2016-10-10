class Support::TicketMessageDrop < BaseDrop
  include ActionView::Helpers::TextHelper
  include ApplicationHelper

  attr_reader :message

  def initialize(message)
    @message = message.decorate
  end

  def date
    message.date
  end

  # date/time when this message was created as a string
  def created_at
    I18n.l(message.created_at, format: :short)
  end

  # the full name of the support recipient
  def full_name
    message.full_name
  end

  # reservations dates tied to this message thread as an html formatted string
  def dates
    @date_presenter = DatePresenter.new(@message.ticket.reservation_dates)
    if !@message.ticket.reservation_details['start_minute'].present? && !@message.ticket.reservation_details['end_minute'].present?
      @date_presenter.selected_dates_summary(wrapper: :div)
    else
      ''
    end
  end

  # reservation dates tied to this message thread in a raw non-html string
  def dates_no_html
    @date_presenter = DatePresenter.new(@message.ticket.reservation_dates)
    if !@message.ticket.reservation_details['start_minute'].present? && !@message.ticket.reservation_details['end_minute'].present?
      @date_presenter.selected_dates_summary_no_html
    else
      ''
    end
  end

  # the contents of this message as an html-formatted string
  def message_html
    simple_format(message.message)
  end

  # the contents of this message
  def message_text
    message.message
  end
end
