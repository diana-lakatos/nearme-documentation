require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @user = FactoryGirl.create(:user)

    @details = {
      bcc: "bcc@test.com",
      from: "from@test.com",
      reply_to: "reply_to@test.com",
      subject: "Test subject"
    }

    PrepareEmail.for('user_mailer/notify_about_wrong_phone_number', @details)
  end

  test "#notify_about_wrong_phone_number" do
    mail = UserMailer.notify_about_wrong_phone_number(@user)

    assert mail.html_part.body.include?(@user.name)
    assert mail.html_part.body.include?(@user.full_mobile_number)

    assert_equal [@user.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end
end
