require 'test_helper'

class InquiryMailerTest < ActiveSupport::TestCase

  setup do
    @inquiry = FactoryGirl.create(:inquiry)
  end

  # TODO: These may need expanding once we have final copy...

  test "listing creator notification works ok" do
    mail = InquiryMailer.listing_creator_notification(@inquiry)

    assert mail.html_part.body.include?(@inquiry.listing.creator.name)
  end

  test "inquiring user notification works ok" do
    mail = InquiryMailer.inquiring_user_notification(@inquiry)

    assert mail.html_part.body.include?(@inquiry.inquiring_user.name)
  end

end
