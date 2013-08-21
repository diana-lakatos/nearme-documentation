require 'test_helper'

class ReservationMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers

  setup do
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.build(:reservation, user: @user)

    @reservation.periods = [ReservationPeriod.new(:date => Date.parse("2012/12/12")), ReservationPeriod.new(:date => Date.parse("2012/12/13"))]
    @reservation.save!

    @expected_dates = "Wednesday, December 12&ndash;Thursday, December 13"

    @details = {
      bcc: "bcc@test.com",
      from: "from@test.com",
      reply_to: "reply_to@test.com",
      subject: "Test subject"
    }

    PrepareEmail.for('layouts/mailer', @details)
  end

  test "#notify_guest_of_cancellation" do
    PrepareEmail.for('reservation_mailer/notify_guest_of_cancellation', @details)

    mail = ReservationMailer.notify_guest_of_cancellation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_guest_of_confirmation" do
    PrepareEmail.for('reservation_mailer/notify_guest_of_confirmation', @details)

    mail = ReservationMailer.notify_guest_of_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_guest_of_expiration" do
    PrepareEmail.for('reservation_mailer/notify_guest_of_expiration', @details)

    mail = ReservationMailer.notify_guest_of_expiration(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_guest_of_rejection" do
    PrepareEmail.for('reservation_mailer/notify_guest_of_rejection', @details)

    mail = ReservationMailer.notify_guest_of_rejection(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.name)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_guest_with_confirmation" do
    PrepareEmail.for('reservation_mailer/notify_guest_with_confirmation', @details)

    mail = ReservationMailer.notify_guest_with_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_host_of_cancellation" do
    PrepareEmail.for('reservation_mailer/notify_host_of_cancellation', @details)

    mail = ReservationMailer.notify_host_of_cancellation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_host_of_confirmation" do
    PrepareEmail.for('reservation_mailer/notify_host_of_confirmation', @details)

    mail = ReservationMailer.notify_host_of_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_host_of_expiration" do
    PrepareEmail.for('reservation_mailer/notify_host_of_expiration', @details)

    mail = ReservationMailer.notify_host_of_expiration(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_host_with_confirmation" do
    PrepareEmail.for('reservation_mailer/notify_host_with_confirmation', @details)

    mail = ReservationMailer.notify_host_with_confirmation(@reservation)

    assert mail.html_part.body.include?( manage_guests_dashboard_path(:token => @reservation.listing_creator.authentication_token) )
    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end

  test "#notify_host_without_confirmation" do
    PrepareEmail.for('reservation_mailer/notify_host_without_confirmation', @details)

    mail = ReservationMailer.notify_host_without_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal @details[:subject], mail.subject
    assert_equal [@details[:from]], mail.from
    assert_equal [@details[:reply_to]], mail.reply_to
    assert_equal [@details[:bcc]], mail.bcc
  end
end

