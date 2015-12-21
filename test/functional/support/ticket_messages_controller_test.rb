require 'test_helper'

class Support::TicketMessagesControllerTest < ActionController::TestCase

  setup do
    Support::Ticket.any_instance.stubs(:admin_emails).returns(['test@test.com'])
    @user = FactoryGirl.create(:user)
    @ticket = FactoryGirl.create(:support_ticket, user: @user)
    sign_in @user
  end

  context '#create' do
    context 'with message params' do
      should 'create message' do
        params = {
          :ticket_id => @ticket.id,
          :support_ticket_message => {
            :message => "New message"
          }
        }

        assert_difference 'Support::TicketMessage.count', 1 do
          post :create, params
        end
      end

      should 'create and close message' do
        params = {
          :commit => "Close Ticket",
          :ticket_id => @ticket.id,
          :support_ticket_message => {
            :message => "New message"
          }
        }

        assert_difference 'Support::TicketMessage.count', 1 do
          post :create, params
        end

        assert @ticket.reload.resolved?
      end
    end

    context 'invalid params' do
      should 'not create message' do
        params = {
          :ticket_id => @ticket.id,
          :support_ticket_message => {
          }
        }
        assert_difference 'Support::TicketMessage.count', 0 do
          post :create, params
        end
      end

      should 'close message' do
        params = {
          :commit => "Close Ticket",
          :ticket_id => @ticket.id,
          :support_ticket_message => {
          }
        }
        assert_difference 'Support::TicketMessage.count', 0 do
          post :create, params
        end

        assert @ticket.reload.resolved?
      end
    end
  end
end
