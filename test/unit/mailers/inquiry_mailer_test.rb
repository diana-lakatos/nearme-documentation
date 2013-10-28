require 'test_helper'

class InquiryMailerTest < ActiveSupport::TestCase

  setup do
    @inquiry = FactoryGirl.create(:inquiry)
    @platform_context = PlatformContext.new
    @subject = "We've passed on your inquiry about {{inquiry.listing.name}}"
  end

  test "listing creator notification works ok" do
    mail = InquiryMailer.listing_creator_notification(@platform_context, @inquiry)
    subject = "New enquiry from #{@inquiry.inquiring_user.name} about #{@inquiry.listing.name}"

    assert_equal subject, mail.subject
    assert mail.subject.include?(@inquiry.listing.name)
    assert mail.reply_to[0].include?(@inquiry.inquiring_user.email)
    assert mail.html_part.body.include?(@inquiry.listing.creator.name)
  end

  test "inquiring user notification works ok" do
    mail = InquiryMailer.inquiring_user_notification(@platform_context, @inquiry)
    subject =  "We've passed on your inquiry about #{@inquiry.listing.name}"
    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@inquiry.inquiring_user.name)
  end

end
