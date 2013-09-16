require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @user = FactoryGirl.create(:user)
    @instance = Instance.first || FactoryGirl.create(:instance)
  end

  test "#notify_about_wrong_phone_number" do
    mail = UserMailer.notify_about_wrong_phone_number(@user)
    subject = "[#{@instance.name}] We couldn't send you text message"

    assert mail.html_part.body.include?(@user.name)
    assert mail.html_part.body.include?(@user.full_mobile_number)

    assert_equal [@user.email], mail.to
    assert_equal subject, mail.subject
  end

  context "#email_verification" do
    setup do
      @mail = UserMailer.email_verification(@user)
    end

    should "email has verification link" do
      assert @mail.html_part.body.include?("/verify/#{@user.id}/#{@user.email_verification_token}")
    end

    should "email has instance name" do
      assert @mail.html_part.body.include?(@user.instance.name)
    end

    should "email has subject" do
      subject = 'Email verification'
      assert_equal subject, @mail.subject
    end

    should "email won't be sent to verified user" do
      @user.update_attribute(:verified_at, Time.zone.now)
      mail = UserMailer.email_verification(@user)
      assert_nil mail.class_name
    end
  end
end
