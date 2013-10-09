require 'test_helper'

class ReservationMailerTest < ActiveSupport::TestCase

  include Rails.application.routes.url_helpers

  setup do
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.build(:reservation, user: @user)
    @reservation.periods = [ReservationPeriod.new(:date => Date.parse("2012/12/12")), ReservationPeriod.new(:date => Date.parse("2012/12/13"))]
    @reservation.save!

    @instance = Instance.default_instance
    @theme = @instance.theme

    @expected_dates = "12 Dec&ndash;13 Dec"
  end

  test "#notify_guest_of_cancellation" do
    mail = ReservationMailer.notify_guest_of_cancellation(@reservation)
    subject = "[#{@instance.name}] A booking you made has been cancelled by the owner"

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal subject, mail.subject
    assert_equal [@theme.support_email], mail.bcc
  end

  test "#notify_guest_of_confirmation" do
    mail = ReservationMailer.notify_guest_of_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal [@theme.support_email], mail.bcc
  end

  test "#notify_guest_of_expiration" do
    mail = ReservationMailer.notify_guest_of_expiration(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal [@theme.support_email], mail.bcc
  end

  test "#notify_guest_of_rejection" do
    mail = ReservationMailer.notify_guest_of_rejection(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.name)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal "[#{@instance.name}] A booking you made has been declined", mail.subject
    assert_equal [@theme.support_email], mail.bcc
  end

  test "#notify_guest_with_confirmation" do
    mail = ReservationMailer.notify_guest_with_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.owner.email], mail.to
    assert_equal [@theme.support_email], mail.bcc
  end

  test "#notify_host_of_cancellation" do
    mail = ReservationMailer.notify_host_of_cancellation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal [@theme.support_email, @reservation.listing.location.email], mail.bcc
  end

  test "#notify_host_of_confirmation" do
    mail = ReservationMailer.notify_host_of_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal [@theme.support_email, @reservation.listing.location.email], mail.bcc
  end

  test "#notify_host_of_expiration" do
    mail = ReservationMailer.notify_host_of_expiration(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal [@theme.support_email, @reservation.listing.location.email], mail.bcc
  end

  test "#notify_host_with_confirmation" do
    mail = ReservationMailer.notify_host_with_confirmation(@reservation)

    assert mail.html_part.body.include?( manage_guests_dashboard_path(:token => @reservation.listing_creator.authentication_token) )
    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal [@theme.support_email, @reservation.listing.location.email], mail.bcc
  end
  test "#notify_host_without_confirmation" do
    mail = ReservationMailer.notify_host_without_confirmation(@reservation)

    assert mail.html_part.body.include?(@reservation.listing.creator.name)
    assert mail.html_part.body.include?(@expected_dates)

    assert_equal [@reservation.listing.creator.email], mail.to
    assert_equal [@theme.support_email, @reservation.listing.location.email], mail.bcc
  end

  test "send to contact person if exists" do
    @reservation.listing.location.update_attribute(:contact_person_id, FactoryGirl.create(:user, :email => 'maciek@example.com').id)
    ['notify_host_of_cancellation', 'notify_host_of_confirmation', 'notify_host_of_expiration',
     'notify_host_with_confirmation', 'notify_host_without_confirmation'].each do |method|
      mail = ReservationMailer.send(method, @reservation)
      assert_equal ['maciek@example.com'], mail.to, "Expected maciek@example.com, got #{mail.to} for #{method}"
    end
  end
end

