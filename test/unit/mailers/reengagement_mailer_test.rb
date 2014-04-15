require 'test_helper'

class ReengagementMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers
  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    @platform_context = PlatformContext.current
    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
  end

  context 'with suggestions' do
    setup do
      @user.stubs(:listings_in_near).returns([FactoryGirl.create(:transactable)])
    end

    should "send no_bookings" do
      mail = ReengagementMailer.no_bookings(@user)
      subject = "[#{@platform_context.decorate.name}] Check out these new Desks in your area!"

      assert mail.html_part.body.include?(@user.first_name)

      assert_equal [@user.email], mail.to
      assert_equal subject, mail.subject
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    should "send one_bookings" do
      @reservation = FactoryGirl.build(:reservation, user: @user)
      @reservation.periods = [ReservationPeriod.new(:date => Date.parse("2012/12/12")), ReservationPeriod.new(:date => Date.parse("2012/12/13"))]
      @reservation.save!

      mail = ReengagementMailer.one_booking(@reservation)
      subject = "[DesksNearMe] Check out these new Desks in your area!"

      assert mail.html_part.body.include?(@user.first_name)
      assert mail.html_part.body.include?(@reservation.listing.name)

      assert_equal [@user.email], mail.to
      assert_equal subject, mail.subject
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

  end

  context 'without suggestions' do
    setup do
      @user.stubs(:listings_in_near).returns([])
    end

    should "not send no_bookings" do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        ReengagementMailer.no_bookings(@user)
      end
    end

    should "send one_bookings" do
      @reservation = FactoryGirl.build(:reservation, user: @user)
      @reservation.periods = [ReservationPeriod.new(:date => Date.parse("2012/12/12")), ReservationPeriod.new(:date => Date.parse("2012/12/13"))]
      @reservation.save!
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        ReengagementMailer.one_booking(@reservation)
      end
    end

  end

  should "set non-transactional email footer for no_bookings" do
    assert ReengagementMailer.non_transactional?
  end

  should "set  non-transactional email footer for one_booking" do
    assert ReengagementMailer.non_transactional?
  end
end
