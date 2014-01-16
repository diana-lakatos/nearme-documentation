# coding: utf-8
require 'test_helper'
require 'helpers/reservation_test_support'

class CompanyMailerTest < ActiveSupport::TestCase
  include ReservationTestSupport

  setup do
    stub_mixpanel
    @company_owner = FactoryGirl.create(:user, :mobile_number => "124456789")
    @company_owner.stubs(:temporary_token).returns('abc')
    @instance = FactoryGirl.create(:instance, :name => 'MyBoat')
    @domain = FactoryGirl.create(:domain, :name => 'notifcations.com', :target => @instance)
    @company = FactoryGirl.create(:company, :creator => @company_owner, :instance => @instance)
    @company.stubs(:created_payment_transfers).returns([
      PaymentTransfer.new(:amount_cents => 7887, :currency => 'USD'),
      PaymentTransfer.new(:amount_cents => 4650, :currency => 'EUR'),
    ])
  end

  test "#notify_host_of_no_payout_option" do
    mail = CompanyMailer.notify_host_of_no_payout_option(@company)
    assert mail.html_part.body.include?('You earned 78.87$, 46.50€'), "Did not include correct information about earnings:\n#{mail.html_part.body}"
    assert mail.html_part.body.include?('But first, we need you to add your PayPal email address so we can make the payment.'), "Did not include correct copy:\n#{mail.html_part.body}"
    assert mail.html_part.body.include?("http://notifcations.com/manage/companies/#{@company.id}/edit?token=abc&track_email_event=true&email_signature=") && mail.html_part.body.include?('#company_paypal_email'), "Did not include correct url to add paypal form:\n#{mail.html_part.body}"
    assert_equal [@company.creator.email], mail.to
  end

end
