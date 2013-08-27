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

  end

  test "#notify_about_wrong_phone_number" do
    PrepareEmail.for('user_mailer/notify_about_wrong_phone_number', @details)

    mail = UserMailer.notify_about_wrong_phone_number(@user)

    assert mail.html_part.body.include?(@user.name)
    assert mail.html_part.body.include?(@user.full_mobile_number)

    assert_equal [@user.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  context "#email_verification" do
    setup do
      PrepareEmail.for('user_mailer/email_verification', @details)
      @mail = UserMailer.email_verification(@user)
    end

    should "email has verification link" do
      assert @mail.html_part.body.include?("/verify/#{@user.id}/#{@user.email_verification_token}")
    end

    should "email has instance name" do
      assert @mail.html_part.body.include?(@user.instance.name)
    end

    should "email won't be sent to verified user" do
      @user.update_attribute(:verified_at, Time.zone.now)
      mail = UserMailer.email_verification(@user)
      assert_nil mail.class_name
    end
  end
end
