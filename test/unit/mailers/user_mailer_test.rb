require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @user = FactoryGirl.create(:user)
    @instance = Instance.default_instance
    @theme = @instance.theme
  end

  test "email has verification link" do
    mail = UserMailer.email_verification(@user, @theme)
    assert mail.html_part.body.include?("/verify/#{@user.id}/#{@user.email_verification_token}")
  end

  test "email has instance name" do
    mail = UserMailer.email_verification(@user, @theme)
    assert mail.html_part.body.include?(@instance.name)
  end

  test "email won't be sent to verified user" do
    @user.update_attribute(:verified_at, Time.zone.now)
    mail = UserMailer.email_verification(@user, @theme)
    assert_nil mail.class_name
  end
end
