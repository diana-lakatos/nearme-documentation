require 'test_helper'

class ReservationMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers

  setup do
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.build(:reservation, user: @user)
    @instance = Instance.first || FactoryGirl.create(:instance)
    @reservation.periods = [ReservationPeriod.new(:date => Date.parse("2012/12/12")), ReservationPeriod.new(:date => Date.parse("2012/12/13"))]
    @reservation.save!

    @expected_dates = "Wednesday, December 12&ndash;Thursday, December 13"
  end

  test "#notify_guest_of_cancellation" do
    mail = ReservationMailer.notify_guest_of_cancellation(@reservation)
    subject = "[#{@instance.name}] A booking you made has been cancelled by the owner"

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal subject, mail.subject
  end

  test "#notify_guest_of_confirmation" do
    mail = ReservationMailer.notify_guest_of_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
  end

  test "#notify_guest_of_expiration" do
    mail = ReservationMailer.notify_guest_of_expiration(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
  end

  test "#notify_guest_of_rejection" do
    mail = ReservationMailer.notify_guest_of_rejection(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.name)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal "[#{@instance.name}] A booking you made has been declined", mail.subject
    assert_equal [@instance.support_email], mail.bcc
  end

  test "#notify_guest_with_confirmation" do
    mail = ReservationMailer.notify_guest_with_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
  end

  test "#notify_host_of_cancellation" do
    mail = ReservationMailer.notify_host_of_cancellation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
  end

  test "#notify_host_of_confirmation" do
    mail = ReservationMailer.notify_host_of_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
  end

  test "#notify_host_of_expiration" do
    mail = ReservationMailer.notify_host_of_expiration(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
  end

  test "#notify_host_with_confirmation" do
    mail = ReservationMailer.notify_host_with_confirmation(@reservation)

    assert mail.html_part.body.include?( manage_guests_dashboard_path(:token => @reservation.listing_creator.authentication_token) )
    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
  end

  test "#notify_host_without_confirmation" do
    mail = ReservationMailer.notify_host_without_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
  end
end

