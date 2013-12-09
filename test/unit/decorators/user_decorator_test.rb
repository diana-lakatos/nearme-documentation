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
  end

end
