require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    @platform_context = PlatformContext.new
    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
  end

  test "email has user first name" do
    mail = UserMailer.notify_about_wrong_phone_number(@platform_context, @user)
    assert mail.subject.include?(@user.first_name)
  end
  
  test "email has correct links" do
    mail = UserMailer.notify_about_wrong_phone_number(@platform_context, @user)
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "has transactional email footer" do
    assert UserMailer.transactional?
  end
end
