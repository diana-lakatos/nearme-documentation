require 'test_helper'

class PostActionMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @user = FactoryGirl.create(:user)
    @platform_context = PlatformContext.new
  end

  test "email has verification link" do
    mail = PostActionMailer.sign_up_verify(@platform_context, @user)
    assert mail.html_part.body.include?("/verify/#{@user.id}/#{@user.email_verification_token}")
  end

  test "email has instance name" do
    mail = PostActionMailer.sign_up_verify(@platform_context, @user)
    assert mail.subject.include?(@platform_context.decorate.name), "#{@platform_context.decorate.name} not included in:\n#{mail.subject}"
  end

  test "email won't be sent to verified user" do
    @user.update_attribute(:verified_at, Time.zone.now)
    mail = PostActionMailer.sign_up_verify(@platform_context, @user)
    assert_nil mail.class_name
  end

  test "sign_up_welcome works ok" do
    mail = PostActionMailer.sign_up_welcome(@platform_context, @user)
    subject = "#{@user.first_name}, welcome to #{@platform_context.decorate.name}!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@user.first_name)
    assert_equal ["micheller@desksnear.me"], mail.from
    assert mail.html_part.body.include?("We are excited to welcome you to #{@platform_context.decorate.name}")
  end

  test "list_draft works ok" do
    mail = PostActionMailer.list_draft(@platform_context, @user)
    subject = "You're almost ready for your first guests!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@user.first_name)
    assert_equal [@user.email], mail.to
    assert mail.html_part.body.include?("There are people looking for desks in your area")
  end

  test "list works ok" do
    mail = PostActionMailer.list(@platform_context, @user)
    subject = "#{@user.first_name}, your new listing looks amazing!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@user.first_name)
    assert_equal [@user.email], mail.to
    assert mail.html_part.body.include?("Your new listing rocks!")
  end

  test "has transactional email footer" do
    ['sign_up_verify', 'sign_up_welcome', 'list_draft', 'list'].each do |method|
      mail = PostActionMailer.send(method, @platform_context, @user)
      assert mail.html_part.body.include?("You are receiving this email because you signed up to Desks Near Me using the email address #{@user.email}")
    end
  end
end
