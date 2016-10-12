require 'test_helper'

class UserMessagesDecoratorTest < ActionView::TestCase
  context 'instance scope' do
    setup do
      @user = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @user3 = FactoryGirl.create(:user)
      @user_message = FactoryGirl.create(:user_message,
                                         thread_context: @user2,
                                         thread_recipient: @user2,
                                         thread_owner: @user,
                                         author: @user,
                                         read_for_recipient: true)

      @answer_user_message = FactoryGirl.create(:user_message,
                                                thread_context: @user2,
                                                thread_recipient: @user2,
                                                thread_owner: @user,
                                                author: @user2)

      @archived_user_message = FactoryGirl.create(:user_message,
                                                  thread_owner: @user,
                                                  thread_context: @user3,
                                                  thread_recipient: @user3,
                                                  author: @user,
                                                  read_for_owner: true,
                                                  archived_for_owner: true,
                                                  archived_for_recipient: false)
      @instance = @user_message.instance
      @second_instance = FactoryGirl.create(:instance)
      FactoryGirl.create(:user_message,
                         thread_context: @user2,
                         thread_recipient: @user2,
                         thread_owner: @user,
                         author: @user,
                         read_for_recipient: true,
                         instance: @second_instance)

      FactoryGirl.create(:user_message,
                         thread_context: @user2,
                         thread_recipient: @user2,
                         thread_owner: @user,
                         author: @user2,
                         instance: @second_instance)

      FactoryGirl.create(:user_message,
                         thread_owner: @user,
                         thread_context: @user3,
                         thread_recipient: @user3,
                         author: @user,
                         read_for_owner: true,
                         archived_for_owner: true,
                         archived_for_recipient: false,
                         instance: @second_instance)

      PlatformContext.current = PlatformContext.new(@instance)
    end

    should 'return inbox' do
      user_inbox = UserMessagesDecorator.new(@user.user_messages, @user).inbox.fetch
      assert_equal 1, user_inbox.size
      thread = user_inbox.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort

      user2_inbox = UserMessagesDecorator.new(@user2.user_messages, @user2).inbox.fetch
      assert_equal 1, user2_inbox.size
      thread = user2_inbox.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort
    end

    should 'return unread' do
      user_unread = UserMessagesDecorator.new(@user.user_messages, @user).unread.fetch
      assert_equal 1, user_unread.size
      thread = user_unread.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort

      user2_unread = UserMessagesDecorator.new(@user2.user_messages, @user2).unread.fetch
      assert_equal 0, user2_unread.size
    end

    should 'return archived' do
      user_archived = UserMessagesDecorator.new(@user.user_messages, @user).archived.fetch
      assert_equal 1, user_archived.size
      thread = user_archived.first[1]
      assert_equal [@archived_user_message.id].sort, thread.map(&:id).sort

      user2_archived = UserMessagesDecorator.new(@user2.user_messages, @user2).archived.fetch
      assert_equal 0, user2_archived.size
    end
  end

  context 'With a message sent from owner to listings creator' do
    setup do
      @owner = FactoryGirl.create(:user)
      @listing = FactoryGirl.create(:transactable)
      @user_message = FactoryGirl.create(:user_message,
                                         thread_context: @listing,
                                         thread_recipient: @listing.administrator,
                                         thread_owner: @owner,
                                         author: @owner,
                                         read_for_recipient: true)
      @listing_administrator = @listing.administrator

      @answer_user_message = FactoryGirl.create(:user_message,
                                                thread_context: @listing,
                                                thread_recipient: @listing.administrator,
                                                thread_owner: @owner,
                                                author: @listing_administrator)

      @listing2 = FactoryGirl.create(:transactable)
      @archived_user_message = FactoryGirl.create(:user_message,
                                                  thread_owner: @owner,
                                                  thread_recipient: @listing2.administrator,
                                                  author: @listing2.administrator,
                                                  read_for_owner: true,
                                                  archived_for_owner: true,
                                                  archived_for_recipient: false)
    end

    should 'return inbox' do
      owners_inbox = UserMessagesDecorator.new(@owner.user_messages, @owner).inbox.fetch
      assert_equal 1, owners_inbox.size
      thread = owners_inbox.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort

      creators_inbox = UserMessagesDecorator.new(@listing_administrator.user_messages,
                                                 @listing_administrator).inbox.fetch
      assert_equal 1, creators_inbox.size
      thread = owners_inbox.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort
    end

    should 'return unread' do
      owners_unread = UserMessagesDecorator.new(@owner.user_messages, @owner).unread.fetch
      assert_equal 1, owners_unread.size
      thread = owners_unread.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort

      creators_unread = UserMessagesDecorator.new(@listing_administrator.user_messages,
                                                  @listing_administrator).unread.fetch
      assert_equal 0, creators_unread.size
    end

    should 'return archived' do
      owners_archived = UserMessagesDecorator.new(@owner.user_messages, @owner).archived.fetch
      assert_equal 1, owners_archived.size
      thread = owners_archived.first[1]
      assert_equal [@archived_user_message.id].sort, thread.map(&:id).sort

      creators_archived = UserMessagesDecorator.new(@listing_administrator.user_messages,
                                                    @listing_administrator).archived.fetch
      assert_equal 0, creators_archived.size
    end
  end

  context 'With a message sent from user to another user' do
    setup do
      @user = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @user3 = FactoryGirl.create(:user)
      @user_message = FactoryGirl.create(:user_message,
                                         thread_context: @user2,
                                         thread_recipient: @user2,
                                         thread_owner: @user,
                                         author: @user,
                                         read_for_recipient: true)

      @answer_user_message = FactoryGirl.create(:user_message,
                                                thread_context: @user2,
                                                thread_recipient: @user2,
                                                thread_owner: @user,
                                                author: @user2)

      @archived_user_message = FactoryGirl.create(:user_message,
                                                  thread_owner: @user,
                                                  thread_context: @user3,
                                                  thread_recipient: @user3,
                                                  author: @user,
                                                  read_for_owner: true,
                                                  archived_for_owner: true,
                                                  archived_for_recipient: false)
    end

    should 'return inbox' do
      user_inbox = UserMessagesDecorator.new(@user.user_messages, @user).inbox.fetch
      assert_equal 1, user_inbox.size
      thread = user_inbox.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort

      user2_inbox = UserMessagesDecorator.new(@user2.user_messages, @user2).inbox.fetch
      assert_equal 1, user2_inbox.size
      thread = user2_inbox.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort
    end

    should 'return unread' do
      user_unread = UserMessagesDecorator.new(@user.user_messages, @user).unread.fetch
      assert_equal 1, user_unread.size
      thread = user_unread.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort

      user2_unread = UserMessagesDecorator.new(@user2.user_messages, @user2).unread.fetch
      assert_equal 0, user2_unread.size
    end

    should 'return archived' do
      user_archived = UserMessagesDecorator.new(@user.user_messages, @user).archived.fetch
      assert_equal 1, user_archived.size
      thread = user_archived.first[1]
      assert_equal [@archived_user_message.id].sort, thread.map(&:id).sort

      user2_archived = UserMessagesDecorator.new(@user2.user_messages, @user2).archived.fetch
      assert_equal 0, user2_archived.size
    end
  end

  context 'With a message sent from host to reservation owner' do
    setup do
      @reservation = FactoryGirl.create(:reservation)
      @host = @reservation.transactable.administrator
      @another_user = FactoryGirl.create(:user)
      @user_message = FactoryGirl.create(:user_message,
                                         thread_context: @reservation,
                                         thread_recipient: @reservation.owner,
                                         thread_owner: @host,
                                         author: @host,
                                         read_for_recipient: true)

      @answer_user_message = FactoryGirl.create(:user_message,
                                                thread_context: @reservation,
                                                thread_recipient: @reservation.owner,
                                                thread_owner: @host,
                                                author: @reservation.owner)

      @archived_user_message = FactoryGirl.create(:user_message,
                                                  thread_owner: @host,
                                                  thread_context: @another_user,
                                                  thread_recipient: @another_user,
                                                  author: @host,
                                                  read_for_owner: true,
                                                  archived_for_owner: true,
                                                  archived_for_recipient: false)
    end

    should 'return inbox' do
      host_inbox = UserMessagesDecorator.new(@host.user_messages, @host).inbox.fetch
      assert_equal 1, host_inbox.size
      thread = host_inbox.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort

      owner_inbox = UserMessagesDecorator.new(@reservation.owner.user_messages, @reservation.owner).inbox.fetch
      assert_equal 1, owner_inbox.size
      thread = owner_inbox.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort
    end

    should 'return unread' do
      host_unread = UserMessagesDecorator.new(@host.user_messages, @host).unread.fetch
      assert_equal 1, host_unread.size
      thread = host_unread.first[1]
      assert_equal [@user_message.id, @answer_user_message.id].sort, thread.map(&:id).sort

      owner_unread = UserMessagesDecorator.new(@reservation.owner.user_messages, @reservation.owner).unread.fetch
      assert_equal 0, owner_unread.size
    end

    should 'return archived' do
      host_archived = UserMessagesDecorator.new(@host.user_messages, @host).archived.fetch
      assert_equal 1, host_archived.size
      thread = host_archived.first[1]
      assert_equal [@archived_user_message.id].sort, thread.map(&:id).sort

      owner_archived = UserMessagesDecorator.new(@reservation.owner.user_messages, @reservation.owner).archived.fetch
      assert_equal 0, owner_archived.size
    end
  end
end
