require 'vcr_setup'
require 'test_helper'

class MailchimpTest < ActiveSupport::TestCase

  # VCR stores result of an api call to avoid making them in the future. First run needs internet connection,
  # all next one doesn't.
  #
  # If you see a long error like: "An HTTP request has been made that VCR does not know how to handle", it means that
  # the test fails - you might want to debug why. I have done this like this: change the name of cassette, invoke 
  # failing test [ warning: this will make a real http call for the first time] and compare the original cassette with 
  # the new one - this should give you a clue what's different

  context "users" do

    setup do
      User.delete_all
      @user = FactoryGirl.create(:user, :email => 'krajek6@gmail.com', :name => 'Maciej Krajowski')
      @company = FactoryGirl.create(:company, :creator => @user, :name => 'Company')
      @location = FactoryGirl.create(:location, :company => @company, :street => 'Street')
      @listing = FactoryGirl.create(:listing, :location => @location)
      # stub urls with dynamic ids to make it work no matter if you invoke only this test, or all tests [ via rake ci for instance ]
      Rails.application.routes.url_helpers.stubs(:verify_user_url).returns('http://example.com/users/verify/1/token')
      Rails.application.routes.url_helpers.stubs(:manage_location_listing_url).returns('http://example.com/manage/locations/1/listings/1')
      Rails.application.routes.url_helpers.stubs(:location_url).returns('http://example.com/manage/locations/1')
    end

    should "be able to export user" do
      assert !@user.mailchimp_exported?
      assert !@user.mailchimp_synchronized?
      VCR.use_cassette('mailchimp_export_user') do
        @result = MAILCHIMP.export_users
      end
      assert_equal({ :new => 1, :updated => 0 }, @result)
      @user.reload
      assert @user.mailchimp_exported?
      assert @user.mailchimp_synchronized?
    end

    should "be able to update existing user" do
      @user.mailchimp_synchronized!
      Timecop.travel(Time.now.utc+10.seconds)
      @user.name = 'John Smith'
      @user.save!
      @user.reload
      assert @user.mailchimp_exported?
      assert !@user.mailchimp_synchronized?
      VCR.use_cassette('mailchimp_update_user') do
        @result = MAILCHIMP.export_users
      end
      @user.reload
      assert_equal({ :new => 0, :updated => 1 }, @result)
      assert @user.mailchimp_synchronized?
    end

    should "skip already synchronized user" do
      @user.mailchimp_synchronized!
      Timecop.travel(Time.now.utc+10.seconds)
      VCR.use_cassette('mailchimp_update_user') do
        @result = MAILCHIMP.export_users end
      assert_equal({ :new => 0, :updated => 0 }, @result)
    end
  end

end
