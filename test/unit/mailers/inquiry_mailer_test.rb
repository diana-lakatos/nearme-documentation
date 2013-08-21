require 'test_helper'

class InquiryMailerTest < ActiveSupport::TestCase

  setup do
    @inquiry = FactoryGirl.create(:inquiry)
    @subject = "We've passed on your inquiry about {{inquiry.listing.name}}"

    @details = {
      subject: @subject
    }

    PrepareEmail.for('layouts/mailer')
  end

  test "listing creator notification works ok" do
    PrepareEmail.for('inquiry_mailer/listing_creator_notification', @details)
    mail = InquiryMailer.listing_creator_notification(@inquiry)

    refute_equal @subject, mail.subject
    assert mail.subject.include?(@inquiry.listing.name)
    assert mail.html_part.body.include?(@inquiry.listing.creator.name)
  end

  test "inquiring user notification works ok" do
    PrepareEmail.for('inquiry_mailer/inquiring_user_notification', @details)
    mail = InquiryMailer.inquiring_user_notification(@inquiry)

    refute_equal @subject, mail.subject
    assert mail.subject.include?(@inquiry.listing.name)
    assert mail.html_part.body.include?(@inquiry.inquiring_user.name)
  end

end
