require 'test_helper'

class UserMessageTest < ActiveSupport::TestCase

  context 'archived_for' do

    setup do
      @listing = FactoryGirl.create(:listing)
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

end
