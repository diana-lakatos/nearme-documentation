require 'test_helper'

class Support::TicketMessageTest < ActiveSupport::TestCase
  context '#populate_data' do
    should 'load data when origin is available' do
      ticket = FactoryGirl.create(:support_ticket, messages_count: 1)
      origin = ticket.messages.first
      message = ticket.messages.new(message: 'test')
      message.populate_data
      assert_equal origin.full_name, message.full_name
      assert_equal origin.email, message.email
      assert_equal origin.subject, message.subject
    end

    should 'be skipped when origin is not available' do
      ticket = FactoryGirl.create(:support_ticket, messages_count: 0)
      message = ticket.messages.new(message: 'test')
      message.populate_data
      assert_nil message.full_name
      assert_nil message.email
      assert_nil message.subject
    end
  end
end
