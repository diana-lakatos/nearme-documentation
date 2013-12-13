require 'test_helper'

class UserDecoratorTest < ActionView::TestCase

  context 'with one message sent to listings creator' do
    setup do
      @listing = FactoryGirl.create(:listing)
      @listing_creator = @listing.creator.decorate
      @listing_message = FactoryGirl.create(:listing_message, listing: @listing)
      @author = @listing_message.author.decorate
    end

    should 'creator should have well formatted 1 message' do
      assert_equal '1', @listing_creator.unread_messages_count
    end

    should 'author should have well formatted no messages' do
      assert_equal '', @author.unread_messages_count
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
