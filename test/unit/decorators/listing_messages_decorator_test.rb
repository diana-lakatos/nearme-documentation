require 'test_helper'

class ListingMessagesDecoratorTest < ActionView::TestCase

  context 'With a message sent from owner to listings creator' do
    setup do
      @owner = FactoryGirl.create(:user)
      @listing_message = FactoryGirl.create(:listing_message,
                                            owner: @owner,
                                            author: @owner,
                                            read: true)
      @listing = @listing_message.listing
      @listing_creator = @listing.creator

      @answer_listing_message = FactoryGirl.create(:listing_message,
                                                   listing: @listing,
                                                   owner: @owner,
                                                   author: @listing_creator)

      @archived_listing_message = FactoryGirl.create(:listing_message,
                                                     owner: @owner,
                                                     author: @listing_creator,
                                                     read: true,
                                                     archived_for_owner: true,
                                                     archived_for_listing: false)
    end

    should 'return inbox' do
      owners_inbox = ListingMessagesDecorator.new(@owner.listing_messages, @owner).inbox.fetch
      assert_equal 1, owners_inbox.size
      thread = owners_inbox.first[1]
      assert_equal [@listing_message.id, @answer_listing_message.id], thread.map(&:id)

      creators_inbox = ListingMessagesDecorator.new(@listing_creator.listing_messages,
                                                    @listing_creator).inbox.fetch
      assert_equal 1, creators_inbox.size
      thread = owners_inbox.first[1]
      assert_equal [@listing_message.id, @answer_listing_message.id], thread.map(&:id)
    end

    should 'return unread' do
      owners_unread = ListingMessagesDecorator.new(@owner.listing_messages, @owner).unread.fetch
      assert_equal 1, owners_unread.size
      thread = owners_unread.first[1]
      assert_equal [@listing_message.id, @answer_listing_message.id], thread.map(&:id)

      creators_unread = ListingMessagesDecorator.new(@listing_creator.listing_messages,
                                                    @listing_creator).unread.fetch
      assert_equal 0, creators_unread.size
    end

    should 'return archived' do
      owners_archived = ListingMessagesDecorator.new(@owner.listing_messages, @owner).archived.fetch
      assert_equal 1, owners_archived.size
      thread = owners_archived.first[1]
      assert_equal [@archived_listing_message.id], thread.map(&:id)

      creators_archived = ListingMessagesDecorator.new(@listing_creator.listing_messages,
                                                    @listing_creator).archived.fetch
      assert_equal 0, creators_archived.size
    end

  end

end
