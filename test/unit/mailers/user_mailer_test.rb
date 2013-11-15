require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @user = FactoryGirl.create(:user)
    @platform_context = PlatformContext.new
  end

  test "email has user first name" do
    mail = UserMailer.notify_about_wrong_phone_number(@platform_context, @user)
    assert mail.subject.include?(@user.first_name)
  end

  test "has transactional email footer" do
    mail = UserMailer.notify_about_wrong_phone_number(@platform_context, @user)
    assert mail.html_part.body.include?("You are receiving this email because you signed up to #{@platform_context.decorate.name} using the email address #{@user.email}")
  end
end
