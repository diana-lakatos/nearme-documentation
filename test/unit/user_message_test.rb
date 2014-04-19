require 'test_helper'

class UserMessageTest < ActiveSupport::TestCase

  context 'archived_for' do

    setup do
      @listing = FactoryGirl.create(:transactable)
      @listing_administrator = @listing.administrator
      @user = FactoryGirl.create(:user)

      @user_message = FactoryGirl.create(:user_message,
        thread_context: @listing,
        thread_owner: @user,
        author: @user,
        thread_recipient: @listing_administrator
      )
    end

    should 'choose write field to store information about archiving' do
      assert_equal @user_message.archived_for?(@user), false
      assert_equal @user_message.archived_for?(@listing_administrator), false
      assert_equal @user_message.archived_column_for(@user), 'archived_for_owner'
      assert_equal @user_message.archived_column_for(@listing_administrator), 'archived_for_recipient'
    end
  end

  context 'mark as read' do

    setup do
      @listing = FactoryGirl.create(:transactable)
      @listing_administrator = @listing.administrator
      @user = FactoryGirl.create(:user)

      @user_message = FactoryGirl.create(:user_message,
        thread_context: @listing,
        thread_owner: @user,
        author: @user,
        thread_recipient: @listing_administrator
      )
    end

    should 'mark as read for thread owner' do
      @user_message.mark_as_read_for!(@user)

      assert @user_message.read_for?(@user)
    end

    should 'mark as read for thread recipient' do
      @user_message.mark_as_read_for!(@listing_administrator)

      assert @user_message.read_for?(@listing_administrator)
    end
  end

  context 'author_has_access_to_message_context' do

    should 'return true if reservation is a thread_context and author is company user' do
      @listing = FactoryGirl.create(:transactable)
      @reservation = FactoryGirl.create(:reservation, listing: @listing)
      @user = FactoryGirl.create(:user)
      CompanyUser.create(company_id: @reservation.company.id, user_id: @user.id)

      @user_message = FactoryGirl.create(:user_message,
                                         thread_context: @listing,
                                         thread_owner: @user,
                                         thread_recipient: @reservation.owner,
                                         author: @user
                                        )

      assert_nothing_raised do
        @user_message.author_has_access_to_message_context?
      end

      assert @user_message.author_has_access_to_message_context?
    end

  end

end
