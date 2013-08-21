require 'test_helper'

class ListingTest < ActiveSupport::TestCase

  setup do
    @listing = FactoryGirl.create(:listing)
    @user = FactoryGirl.create(:user)
    @subject = "Test subject"

    details = {
      subject: @subject
    }

    PrepareEmail.for('listing_mailer/share', details)
    PrepareEmail.for('layouts/mailer', details)
  end

  test "#share" do
    mail = ListingMailer.share(@listing, 'jimmy@test.com', 'Jimmy Falcon', @user, 'Check this out!')

    assert_equal @subject, mail.subject
    assert mail.html_part.body.include?(@user.name)
    assert mail.html_part.body.include?('They also wanted to say:')
    assert mail.html_part.body.include?('Check this out!')

    assert_equal ['jimmy@test.com'], mail.to
  end

  test "#share without message" do
    mail = ListingMailer.share(@listing, 'jimmy@test.com', 'Jimmy Falcon', @user)

    assert mail.html_part.body.include?(@user.name)
    refute mail.html_part.body.include?('They also wanted to say:')

    assert_equal ['jimmy@test.com'], mail.to
  end
end
