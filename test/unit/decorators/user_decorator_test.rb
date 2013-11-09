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
  end

end
