require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @user = FactoryGirl.create(:user)
    @platform_context = PlatformContext.new
  end

  test "email has verification link" do
    mail = UserMailer.email_verification(@platform_context, @user)
    assert mail.html_part.body.include?("/verify/#{@user.id}/#{@user.email_verification_token}")
  end

  test "email has instance name" do
    mail = UserMailer.email_verification(@platform_context, @user)
    assert mail.html_part.body.include?(@platform_context.decorate.name), "#{@platform_context.decorate.name} not included in:\n#{mail.html_part.body}"
  end

  test "email won't be sent to verified user" do
    @user.update_attribute(:verified_at, Time.zone.now)
    mail = UserMailer.email_verification(@platform_context, @user)
    assert_nil mail.class_name
  end
end
