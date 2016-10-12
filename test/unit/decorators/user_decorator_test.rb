require 'test_helper'

class UserDecoratorTest < ActionView::TestCase
  context 'with one message sent to listings creator' do
    setup do
      @instance = FactoryGirl.create(:instance)
      @listing = FactoryGirl.create(:transactable)
      @listing_creator = @listing.creator.decorate
      @author = FactoryGirl.create(:user)
      PlatformContext.current = PlatformContext.new(@instance)
      @user_message = FactoryGirl.create(:user_message, thread_context: @listing, author: @author, thread_owner: @author, thread_recipient: @listing.administrator, instance: @instance)
      @author = @author.decorate
    end

    should 'creator should have 1 user message' do
      assert_equal 1, @listing_creator.unread_user_message_threads_count_for(@instance)
    end

    should 'author should have no user messages' do
      assert_equal 0, @author.unread_user_message_threads_count_for(@instance)
    end

    context '#social_connections_for' do
      should 'return nil for unexisting connection' do
        @author.expects(:social_connections).returns([])
        assert_nil @author.social_connections_for('facebook')
      end

      should 'return connection for existing connection' do
        connection = stub(provider: 'facebook')
        @author.expects(:social_connections).returns([connection])
        assert_equal connection, @author.social_connections_for('facebook')
      end
    end
  end
end
