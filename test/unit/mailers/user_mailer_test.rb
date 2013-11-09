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
end
