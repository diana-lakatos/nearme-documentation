class Support::TicketMessageDrop < BaseDrop
  include ActionView::Helpers::TextHelper

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def date
    message.date
  end

  def created_at
    I18n.l(message.created_at, format: :short)
  end

  def full_name
    message.full_name
  end

  def dates
    @date_presenter = DatePresenter.new(@message.ticket.reservation_dates)
    if !@message.ticket.reservation_details['start_minute'].present? && !@message.ticket.reservation_details['end_minute'].present?
      @date_presenter.selected_dates_summary(wrapper: :div)
    else
      ''
    end
  end

  def dates_no_html
    @date_presenter = DatePresenter.new(@message.ticket.reservation_dates)
    if !@message.ticket.reservation_details['start_minute'].present? && !@message.ticket.reservation_details['end_minute'].present?
      @date_presenter.selected_dates_summary_no_html
    else
      ''
    end
  end

  def message_html
    simple_format(message.message)
  end

  def message_text
    message.message
  end
end
