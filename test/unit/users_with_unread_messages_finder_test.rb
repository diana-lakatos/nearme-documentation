require 'test_helper'

class UsersWithUnreadMessagesFinderTest < ActiveSupport::TestCase
  setup do
    @joe = FactoryGirl.create(:user)
    @jimmy = FactoryGirl.create(:user)

    @listing = FactoryGirl.create(:transactable)
    @listing_administrator = @listing.administrator

    # We create three messages but we should only get
    # two users as two messages are for the same user
    @user_message_1 = FactoryGirl.create(:user_message,
                                         thread_context: @listing,
                                         thread_owner: @joe,
                                         author: @joe,
                                         thread_recipient: @listing_administrator
                                        )
    @user_message_1.update_column(:created_at, Time.now - 2.days)

    @user_message_2 = FactoryGirl.create(:user_message,
                                         thread_context: @listing,
                                         thread_owner: @joe,
                                         author: @joe,
                                         thread_recipient: @listing_administrator
                                        )
    @user_message_2.update_column(:created_at, Time.now - 2.days)

    @user_message_3 = FactoryGirl.create(:user_message,
                                         thread_context: @listing,
                                         thread_owner: @joe,
                                         author: @joe,
                                         thread_recipient: @jimmy
                                        )
    @user_message_3.update_column(:created_at, Time.now - 2.days)
  end

  should 'find correct number of messages' do
    users = UsersWithUnreadMessagesFinder.new.find
    assert_equal 2, users.length

    users.each do |user|
      user.user_messages.update_all(unread_last_reminded_at: Time.now)
    end

    # Now there should be 0
    users = UsersWithUnreadMessagesFinder.new.find
    assert_equal 0, users.length
  end
end
