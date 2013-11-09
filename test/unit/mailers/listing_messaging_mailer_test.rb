require 'test_helper'

class ListingMessagingMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @listing_message = FactoryGirl.create(:listing_message)
    @user = FactoryGirl.create(:user)
    @listing_message.owner = @user
    @platform_context = PlatformContext.new
  end

  test "#email_message_from_guest" do
    mail = ListingMessagingMailer.email_message_from_guest(@platform_context, @listing_message)

    assert mail.html_part.body.include?(@listing_message.owner.first_name)

    assert_equal [@listing_message.listing.administrator.email], mail.to
  end

  test "#email_message_from_host" do
    @listing_message.author = @listing_message.listing.administrator 
    mail = ListingMessagingMailer.email_message_from_host(@platform_context, @listing_message)

    assert mail.html_part.body.include?(@listing_message.listing.administrator.first_name)

    assert_equal [@listing_message.owner.email], mail.to
  end
end
