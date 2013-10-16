require 'test_helper'

class UserMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @user = FactoryGirl.create(:user)
    @request_context = Controller::RequestContext.new
  end

  test "email has verification link" do
    mail = UserMailer.email_verification(@request_context, @user)
    assert mail.html_part.body.include?("/verify/#{@user.id}/#{@user.email_verification_token}")
  end

  test "email has instance name" do
    mail = UserMailer.email_verification(@request_context, @user)
    assert mail.html_part.body.include?(@request_context.name), "#{@request_context.name} not included in:\n#{mail.html_part.body}"
  end

  test "email won't be sent to verified user" do
    @user.update_attribute(:verified_at, Time.zone.now)
    mail = UserMailer.email_verification(@request_context, @user)
    assert_nil mail.class_name
  end
end
