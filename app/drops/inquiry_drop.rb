class InquiryDrop < BaseDrop

  attr_reader :inquiry

  # listing_creator_name
  #   name of the creator of the listing to which this inquiry belongs
  # inquiring_user_name
  #   name of the inquiring user
  # inquiring_user
  #   the inquiring user object
  # listing
  #   the listing to which this inquiry belongs
  # message
  #   the message of the inquiry
  delegate :listing_creator_name, :inquiring_user_name, :inquiring_user,
    :listing, :message, to: :inquiry

  def initialize(inquiry)
    @inquiry = inquiry
  end

end
