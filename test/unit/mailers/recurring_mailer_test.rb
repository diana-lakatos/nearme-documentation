require 'test_helper'

class RecurringMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    stub_mixpanel
    @company = FactoryGirl.create(:company)
    @platform_context = PlatformContext.current
    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
  end

  test "analytics works ok" do
    mail = RecurringMailer.analytics(@company, @company.creator)
    subject = "#{@company.creator.first_name}, we have potential guests for you!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@company.creator.first_name)
    assert_equal [@company.creator.email], mail.to
    assert mail.html_part.body.include?("Add more information or upload additional photos to make your Desk look even better!")
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "request_photos works ok" do
    @listing = FactoryGirl.create(:transactable)
    @user = @listing.administrator
    mail = RecurringMailer.request_photos(@listing)
    subject = "Give the final touch to your listing with some photos!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@user.first_name)
    assert_equal [@user.email], mail.to
    assert mail.html_part.body.include?("Listings with photos have 10x chances of getting rented.")
    assert mail.html_part.body.include?(@listing.name)
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "share works ok" do
    @reservation = FactoryGirl.create(:past_reservation)
    @listing = @reservation.listing
    @user = @listing.administrator
    mail = RecurringMailer.share(@listing)
    subject = "Share your listing '#{@listing.name}' at #{@listing.location.street } and increase bookings!"

    assert_equal subject, mail.subject
    assert mail.html_part.body.include?(@user.first_name)
    assert_equal [@user.email], mail.to
    assert mail.html_part.body.include?("Share your listing on Facebook, Twitter, and LinkedIn, and start seeing #{@platform_context.decorate.lessees} book your Desk.")
    assert mail.html_part.body.include?(@listing.name)
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body
  end

  test "analytics has non-transactional email footer" do
    assert RecurringMailer.non_transactional?
  end

  test "request_photos and share has non-transactional email footer" do
    assert RecurringMailer.non_transactional?
  end
end
