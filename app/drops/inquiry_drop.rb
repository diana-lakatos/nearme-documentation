class InquiryDrop < BaseDrop
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def listing_creator_name
    @inquiry.listing_creator_name
  end

  def inquiring_user_name
    @inquiry.inquiring_user_name
  end

  def inquiring_user
    @inquiry.inquiring_user
  end

  def listing
    @inquiry.listing
  end

  def message
    @inquiry.message
  end
end
