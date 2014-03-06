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

  def message_html
    simple_format(message.message)
  end

  def message_text
    message.message
  end
end
