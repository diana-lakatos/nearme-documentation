require 'test_helper'

class PostActionMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers

  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    @platform_context = PlatformContext.current
    @instance = @platform_context.instance
    InstanceAdmin.create(:user_id => @user.id).update_attribute(:instance_id, @instance.id)
    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
  end

  test "email has verification link" do
    mail = PostActionMailer.sign_up_verify(@user)
    assert mail.html_part.body.include?("/verify/#{@user.id}/#{@user.email_verification_token}")
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "email has instance name" do
    mail = PostActionMailer.sign_up_verify(@user)
    assert mail.subject.include?(@platform_context.decorate.name), "#{@platform_context.decorate.name} not included in:\n#{mail.subject}"
  end

  test "email won't be sent to verified user" do
    @user.update_attribute(:verified_at, Time.zone.now)
    mail = PostActionMailer.sign_up_verify(@user)
    assert_nil mail.class_name
  end

  test "sign_up_welcome works ok" do
    mail = PostActionMailer.sign_up_welcome(@user)
    subject = "#{@user.first_name}, welcome to #{@platform_context.decorate.name}!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@user.first_name)
    assert mail.html_part.body.include?("We are excited to welcome you to #{@platform_context.decorate.name}")
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "created_by_instance_admin works ok" do
    @new_user = FactoryGirl.create(:user)
    @creator = FactoryGirl.create(:user)

    # We freeze time for this test since we're asserting the presence of
    # a temporary login token. We rely on semantics that for any given expiry
    # time, two tokens are the same for the same user. This is somewhat of
    # a hack.
    Timecop.freeze do
      mail = PostActionMailer.created_by_instance_admin(@new_user , @creator)
      subject = "#{@new_user.first_name }, you were invited to #{@platform_context.instance.name } by #{@creator.name}!"
      assert_equal subject, mail.subject
      assert mail.html_part.body.include?("Welcome, #{@new_user.first_name}"), "Could not find 'Welcome, #{@new_user.first_name}' in #{mail.html_part.body}"
      assert mail.html_part.body.include?("You have been invited by #{@creator.name} to join #{@platform_context.instance.name}!"), "Could not find 'ou have been invited by #{@creator.name} to join #{@platform_context.instance.name}!' in #{mail.html_part.body}"
      assert mail.html_part.body.include?(CGI.escape(@new_user.temporary_token)), "Could not find User's authentication token in the email"
      refute mail.html_part.body.include?(CGI.escape(@creator.temporary_token)), "Authentication token is included in the email, which is sent the new user - new user should not have access to creator's account!"
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end
  end

  test "list_draft works ok" do
    mail = PostActionMailer.list_draft(@user)
    subject = "You're almost ready for your first guests!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@user.first_name)
    assert_equal [@user.email], mail.to
    assert mail.html_part.body.include?("There are people looking for Desks in your area")
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "list works ok" do
    @listing = FactoryGirl.create(:transactable)
    @user = @listing.creator
    mail = PostActionMailer.list(@user)
    subject = "#{@user.first_name}, your new listing looks amazing!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@user.first_name)
    assert_equal [@user.email], mail.to
    assert mail.html_part.body.include?("Your new listing rocks!")
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "unsubscription works ok" do
    mailer_name = 'recurring_mailer/request_photos'
    mail = PostActionMailer.unsubscription(@user, mailer_name)
    subject = "Successfully unsubscribed"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(subject)
    assert_equal [@user.email], mail.to
    assert mail.html_part.body.include?(mailer_name.split('/').last.humanize)
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "instance_created works ok" do
    mail = PostActionMailer.instance_created(@instance, @user, 'password')
    subject = "Instance created"

    assert_equal subject, mail.subject
    assert_equal [@user.email], mail.to
    assert mail.html_part.body.include?("Password: password")
    assert mail.html_part.body.include?("Email: #{@user.email}")
    assert mail.html_part.body.include?("Your marketplace, #{@instance.name}")
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "has transactional email footer" do
    assert PostActionMailer.transactional?
  end
end
