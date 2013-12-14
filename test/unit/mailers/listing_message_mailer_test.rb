require 'test_helper'

class ListingMessageMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    stub_mixpanel
    @listing_message = FactoryGirl.create(:listing_message)
    @user = FactoryGirl.create(:user)
    @listing_message.owner = @user
    @platform_context = PlatformContext.new
    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
  end

  test "#email_message_from_guest" do
    mail = ListingMessageMailer.email_message_from_guest(@platform_context, @listing_message)

    assert mail.html_part.body.include?(@listing_message.owner.first_name)

    assert_equal [@listing_message.listing.administrator.email], mail.to
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "#email_message_from_host" do
    @listing_message.author = @listing_message.listing.administrator 
    mail = ListingMessageMailer.email_message_from_host(@platform_context, @listing_message)

    assert mail.html_part.body.include?(@listing_message.listing.administrator.first_name)

    assert_equal [@listing_message.owner.email], mail.to
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end
end
