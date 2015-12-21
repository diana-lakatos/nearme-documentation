require 'test_helper'

class Support::TicketsControllerTest < ActionController::TestCase

  setup do
    Support::Ticket.any_instance.stubs(:admin_emails).returns(['test@test.com'])
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  context '#index' do
    should 'be protected' do
      sign_out @user
      get :index
      assert_response 302
    end

    should 'work' do
      get :index
      assert_response :success
    end
  end

  context '#new' do
    should 'work' do
      get :new
      assert_response :success
    end
  end

  context '#show' do
    setup do
      @ticket = FactoryGirl.create(:support_ticket, user: @user)

    end
    should 'be protected' do
      sign_out @user
      get :show, id: @ticket.id
      assert_response 302
    end

    should 'work' do
      get :show, id: @ticket.id
      assert_response :success
    end
  end

  context '#create' do
    context 'logged' do
      should 'create ticket' do
        params = {
          "support_ticket" => {
            "messages_attributes" => [
              "message" => 'Message',
              "subject" => 'Subject'
            ]
          }
        }

        assert_difference 'Support::Ticket.count', 1 do
          assert_difference 'Support::TicketMessage.count', 1 do
            post :create, params
          end
        end
      end
    end

    context 'unlogger' do
      should 'create ticket' do
        params = {
          "support_ticket" => {
            "messages_attributes" => [
              "message" => 'Message',
              "full_name" => 'Johnny',
              "subject" => "Subject",
              "email" => "email"
            ]
          }
        }

        assert_difference 'Support::Ticket.count', 1 do
          assert_difference 'Support::TicketMessage.count', 1 do
            post :create, params
          end
        end
      end
    end
  end
end
