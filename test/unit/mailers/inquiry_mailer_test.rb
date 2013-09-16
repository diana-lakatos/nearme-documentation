require 'test_helper'

class InquiryMailerTest < ActiveSupport::TestCase

  setup do
    @inquiry = FactoryGirl.create(:inquiry)
    @instance = Instance.first || FactoryGirl.create(:instance)
    @subject = "We've passed on your inquiry about {{inquiry.listing.name}}"
  end

  test "listing creator notification works ok" do
    mail = InquiryMailer.listing_creator_notification(@instance.id, @inquiry.id)
    subject = "New enquiry from #{@inquiry.inquiring_user.name} about #{@inquiry.listing.name}"

    assert_equal subject, mail.subject
    assert mail.subject.include?(@inquiry.listing.name)
    assert mail.html_part.body.include?(@inquiry.listing.creator.name)
  end

  test "inquiring user notification works ok" do
    mail = InquiryMailer.inquiring_user_notification(@instance.id, @inquiry.id)
    subject =  "We've passed on your inquiry about #{@inquiry.listing.name}"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@inquiry.inquiring_user.name)
  end

end
