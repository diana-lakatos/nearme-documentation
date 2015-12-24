require 'test_helper'

class Support::Tickets::TicketMessageAttachmentsControllerTest < ActionController::TestCase

  setup do
    Support::Ticket.any_instance.stubs(:admin_emails).returns(['test@test.com'])
    @user = FactoryGirl.create(:user)
    @ticket = FactoryGirl.create(:support_ticket, user: @user)
    sign_in @user
  end

  context '#create' do
    should 'create message' do
      params = {
        ticket_id: @ticket.id,
        support_ticket_message_attachment: FactoryGirl.attributes_for(:support_ticket_message_attachment)
      }

      assert_difference 'Support::TicketMessageAttachment.count', 1 do
        post :create, params
      end
      response = ActiveSupport::JSON.decode @response.body
      assert response['attachment_content'].present?
      assert response['modal_content'].present?

    end

  end

  context '#update' do
    should 'update tag' do
      @attachment = FactoryGirl.create(:support_ticket_message_attachment, ticket: @ticket, uploader: @user)
      assert_no_difference 'Support::TicketMessageAttachment.count' do
        put :update, { ticket_id: @ticket.id, id: @attachment.id, support_ticket_message_attachment: { :tag => 'Purchase Order' } }
      end
      response = ActiveSupport::JSON.decode @response.body
      assert response['attachment_content'].include?('Purchase Order')
      refute response['attachment_content'].include?('Informational')
      assert_equal 'Purchase Order', @attachment.reload.tag
      assert_equal @attachment.id, response['attachment_id'].to_i
    end
  end
end
