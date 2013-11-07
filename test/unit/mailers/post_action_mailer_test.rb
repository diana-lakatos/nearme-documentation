require 'test_helper'

class PostActionMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers

  setup do
    @user = FactoryGirl.create(:user)
    FactoryGirl.create(:instance)
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

  test "created_by_instance_admin works ok" do
    @new_user = FactoryGirl.create(:user)
    @creator = FactoryGirl.create(:user)
    @platform_context = PlatformContext.new
    mail = PostActionMailer.created_by_instance_admin(@platform_context, @new_user , @creator)
    subject = "#{@new_user.first_name }, you were invited to #{@platform_context.instance.name } by #{@creator.name}!"
    assert_equal subject, mail.subject
    assert mail.html_part.body.include?("Welcome, #{@new_user.first_name}"), "Could not find 'Welcome, #{@new_user.first_name}' in #{mail.html_part.body}"
    assert mail.html_part.body.include?("You have been invited by #{@creator.name} to join #{@platform_context.instance.name}!"), "Could not find 'ou have been invited by #{@creator.name} to join #{@platform_context.instance.name}!' in #{mail.html_part.body}"
    assert mail.html_part.body.include?(@new_user.authentication_token), "Could not find User's authentication token in the email"
    refute mail.html_part.body.include?(@creator.authentication_token), "Authentication token is included in the email, which is sent the new user - new user should not have access to creator's account!"
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
end
