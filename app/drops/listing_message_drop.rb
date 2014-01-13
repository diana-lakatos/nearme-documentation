class ListingMessageDrop < BaseDrop

  attr_reader :listing_message
  delegate :body, to: :listing_message

  def initialize(listing_message)
    @listing_message = listing_message
  end

  def url
    routes.listing_listing_message_path(@listing_message.listing, @listing_message, :token => @listing_message.recipient.try(:temporary_token))
  end

  def url_with_tracking
    routes.listing_listing_message_path(@listing_message.listing, @listing_message, :token => @listing_message.recipient.try(:temporary_token), :track_email_event => true)
  end

  def owner_first_name
    @listing_message.owner.first_name
  end

  def author_first_name
    @listing_message.author.first_name
  end

end
