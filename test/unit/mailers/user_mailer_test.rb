require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  test "email has verification link" do
    mail = UserMailer.email_verification(@user.instance, @user.id)
    assert mail.html_part.body.include?("/verify/#{@user.id}/#{@user.email_verification_token}")
  end

  test "email has instance name" do
    mail = UserMailer.email_verification(@user.instance, @user.id)
    assert mail.html_part.body.include?(@user.instance.name)
  end

  test "email won't be sent to verified user" do
    @user.update_attribute(:verified_at, Time.zone.now)
    mail = UserMailer.email_verification(@user.instance, @user.id)
    assert_nil mail.class_name
  end
end
