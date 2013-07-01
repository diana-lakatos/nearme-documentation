require 'test_helper'

class ReservationMailerTest < ActiveSupport::TestCase

  setup do
    @reservation = FactoryGirl.create(:reservation)
  end

  test "notify guest of cancellation" do
    mail = ReservationMailer.notify_guest_of_cancellation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end

  test "notify guest of confirmation" do
    mail = ReservationMailer.notify_guest_of_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end

  test "notify guest of expiration" do
    mail = ReservationMailer.notify_guest_of_expiration(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end

  test "notify guest of rejection" do
    mail = ReservationMailer.notify_guest_of_rejection(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.name)
  end

  test "notify guest with confirmation" do
    mail = ReservationMailer.notify_guest_with_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end

  test "notify host of cancellation" do
    mail = ReservationMailer.notify_host_of_cancellation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end

  test "notify host of confirmation" do
    mail = ReservationMailer.notify_host_of_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end

  test "notify host of expiration" do
    mail = ReservationMailer.notify_host_of_expiration(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end

  test "notify host with confirmation" do
    mail = ReservationMailer.notify_host_with_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end

  test "notify host without confirmation" do
    mail = ReservationMailer.notify_host_without_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
  end


end