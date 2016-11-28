# frozen_string_literal: true
class Support::TicketMessageDrop < BaseDrop
  include ActionView::Helpers::TextHelper
  include ApplicationHelper

  # @return [Support::TicketMessageDrop]
  attr_reader :message

  def initialize(message)
    @message = message.decorate
  end

  # @return [String] date/time when this message was created
  def created_at
    I18n.l(message.created_at, format: :short)
  end

  # @!method full_name
  #   @return [String] the full name of the support recipient
  delegate :full_name, to: :message

  # @return [String] reservations dates tied to this message thread as an html formatted string
  def dates
    @date_presenter = DatePresenter.new(@message.ticket.reservation_dates)
    if !@message.ticket.reservation_details['start_minute'].present? && !@message.ticket.reservation_details['end_minute'].present?
      @date_presenter.selected_dates_summary(wrapper: :div)
    else
      ''
    end
  end

  # @return [String] reservation dates tied to this message thread in a raw non-html string
  def dates_no_html
    @date_presenter = DatePresenter.new(@message.ticket.reservation_dates)
    if !@message.ticket.reservation_details['start_minute'].present? && !@message.ticket.reservation_details['end_minute'].present?
      @date_presenter.selected_dates_summary_no_html
    else
      ''
    end
  end

  # @return [String] the contents of this message as an html-formatted string
  def message_html
    simple_format(message.message)
  end

  # @return [String] the contents of this message
  def message_text
    message.message
  end
end
