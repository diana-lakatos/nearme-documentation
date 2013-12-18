class InquiryDrop < BaseDrop

  attr_reader :inquiry
  delegate :listing_creator_name, :inquiring_user_name, :inquiring_user,
    :listing, :message, to: :inquiry

  def initialize(inquiry)
    @inquiry = inquiry
  end

end
