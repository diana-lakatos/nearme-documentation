require 'test_helper'

class UserDecoratorTest < ActionView::TestCase

  context 'with one message sent to listings creator' do
    setup do
      @listing = FactoryGirl.create(:listing)
      @listing_creator = @listing.creator.decorate
      @listing_message = FactoryGirl.create(:listing_message, listing: @listing)
      @author = @listing_message.author.decorate
    end

    should 'creator should have 1 message' do
      assert_equal 1, @listing_creator.unread_listing_message_threads.fetch.size
    end

    should 'author should have no messages' do
      assert_equal 0, @author.unread_listing_message_threads.fetch.size
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
