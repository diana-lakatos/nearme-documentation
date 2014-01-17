require 'test_helper'

class UserMessageMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    @user_message = FactoryGirl.create(:user_message, thread_owner: @user, author: @user)
    @user_message.thread_recipient = @user_message.thread_context.administrator
    @user_message.save
    @platform_context = PlatformContext.new
    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
  end

  test "#email_message_from_guest" do
    mail = UserMessageMailer.email_message_from_guest(@platform_context, @user_message)

    assert_contains @user_message.thread_owner.first_name, mail.html_part.body
    assert_contains @user_message.body, mail.html_part.body

    assert_equal [@user_message.thread_context.administrator.email], mail.to
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "#email_message_from_host" do
    @user_message.author = @user_message.thread_context.administrator 
    mail = UserMessageMailer.email_message_from_host(@platform_context, @user_message)

    assert_contains @user_message.thread_context.administrator.first_name, mail.html_part.body
    assert_contains @user_message.body, mail.html_part.body
    
    assert_equal [@user_message.thread_owner.email], mail.to
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end
end

