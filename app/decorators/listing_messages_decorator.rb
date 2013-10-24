class ListingMessagesDecorator < Draper::CollectionDecorator

  def initialize(collection, user)
    @user = user
    super(collection)
  end

  def inbox
    @threaded_listing_messages = threaded_listing_messages.reject {|key, listing_messages|
      listing_messages.all?{|listing_message| listing_message.archived_for?(@user) }
    }
    self
  end

  def unread
    @threaded_listing_messages = threaded_listing_messages.select { |key, listing_messages|
      listing_messages.any?{|listing_message| listing_message.unread_for?(@user) }
    }
    self
  end

  def archived
    @threaded_listing_messages = threaded_listing_messages.select { |key, listing_messages|
      listing_messages.all?{|listing_message| listing_message.archived_for?(@user) }
    }
    self
  end

  def fetch
    threaded_listing_messages
  end

  private
  def threaded_listing_messages
    @threaded_listing_messages ||= decorated_collection.group_by{|listing_message|
      [listing_message.owner_id, listing_message.listing_id]
    }.sort_by{|key, listing_messages| listing_messages.last.created_at }.reverse
  end

end
