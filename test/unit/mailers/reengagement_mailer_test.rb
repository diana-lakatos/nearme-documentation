require 'test_helper'

class ReengagementMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    @user = FactoryGirl.create(:user)
    @platform_context = PlatformContext.new
  end

  test "#no_bookings" do
    mail = ReengagementMailer.no_bookings(@platform_context, @user)
    subject = "[#{@platform_context.decorate.name}] Check out these new spaces in your area!"

    assert mail.html_part.body.include?(@user.first_name)

    assert_equal [@user.email], mail.to
    assert_equal subject, mail.subject
  end

  test "#one_booking" do
    @reservation = FactoryGirl.build(:reservation, user: @user)
    @reservation.periods = [ReservationPeriod.new(:date => Date.parse("2012/12/12")), ReservationPeriod.new(:date => Date.parse("2012/12/13"))]
    @reservation.save!

    mail = ReengagementMailer.one_booking(@platform_context, @reservation)
    subject = "[#{@platform_context.decorate.name}] Check out these new spaces in your area!"

    assert mail.html_part.body.include?(@user.first_name)
    assert mail.html_part.body.include?(@reservation.listing.name)

    assert_equal [@user.email], mail.to
    assert_equal subject, mail.subject
  end

  test "no_bookings has non-transactional email footer" do
    assert ReengagementMailer.non_transactional?
  end

  test "one_booking has non-transactional email footer" do
    assert ReengagementMailer.non_transactional?
  end
end
