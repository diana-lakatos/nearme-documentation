require 'test_helper'

class UserMessageTest < ActiveSupport::TestCase
  def create_user_message
    @transactable = FactoryGirl.create(:transactable)
    @transactable_administrator = @transactable.administrator
    @user = FactoryGirl.create(:user)

    @user_message = FactoryGirl.create(:user_message,
                                       thread_context: @transactable,
                                       thread_owner: @user,
                                       author: @user,
                                       thread_recipient: @transactable_administrator
                                      )
  end

  context 'archived_for' do
    setup do
      create_user_message
    end

    should 'choose write field to store information about archiving' do
      assert_equal @user_message.archived_for?(@user), false
      assert_equal @user_message.archived_for?(@transactable_administrator), false
      assert_equal @user_message.archived_column_for(@user), 'archived_for_owner'
      assert_equal @user_message.archived_column_for(@transactable_administrator), 'archived_for_recipient'
    end
  end

  context 'mark as read' do
    setup do
      create_user_message
    end

    should 'mark as read for thread owner' do
      @user_message.mark_as_read_for!(@user)

      assert @user_message.read_for?(@user)
    end

    should 'mark as read for thread recipient' do
      @user_message.mark_as_read_for!(@transactable_administrator)

      assert @user_message.read_for?(@transactable_administrator)
    end
  end

  context 'author_has_access_to_message_context' do
    should 'return true if reservation is a thread_context and author is company user' do
      @transactable = FactoryGirl.create(:transactable)
      @reservation = FactoryGirl.create(:reservation, transactable: @transactable)
      @user = FactoryGirl.create(:user)
      CompanyUser.create(company_id: @reservation.company.id, user_id: @user.id)

      @user_message = FactoryGirl.create(:user_message,
                                         thread_context: @transactable,
                                         thread_owner: @user,
                                         thread_recipient: @reservation.owner,
                                         author: @user)

      assert_nothing_raised do
        @user_message.author_has_access_to_message_context?
      end

      assert @user_message.author_has_access_to_message_context?
    end
  end

  context 'update_unread_message_counter_for' do
    setup do
      create_user_message
    end

    should 'run' do
      assert @user_message.update_unread_message_counter_for(@user)
    end
  end
end
