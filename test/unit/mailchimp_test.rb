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
      create_users
      stubs_urls
    end

    should "should be not exported before first export" do
      all_users.each { |u| assert !u.mailchimp_exported? }
    end

    should "not be synchronized when it was not even exported" do
      all_users.each { |u| assert !u.mailchimp_synchronized? }
    end

    should "be able to export users" do
      VCR.use_cassette('mailchimp_export_user') do
        @result = MAILCHIMP.export_users
      end
      
      assert_equal({"add_count"=>4, "update_count"=>0, "error_count"=>0, "errors"=>[]}, @result)
      all_users.each do |u|
        u.reload
        assert u.mailchimp_exported?
        assert u.mailchimp_synchronized?
      end
    end
    
    context 'with Timecop' do

    teardown do
      Timecop.return
    end

    should "be able to update existing user" do
      all_users.each { |u| u.mailchimp_synchronized! }
      u = all_users[0]
      Timecop.travel(Time.zone.now+10.seconds)
      u.name = 'Updated Name'
      u.save!
      u.reload
      assert u.mailchimp_exported?
      assert !u.mailchimp_synchronized?
      VCR.use_cassette('mailchimp_update_user') do
        @result = MAILCHIMP.export_users
      end
      u.reload
      assert_equal({"add_count"=>0, "update_count"=>1, "error_count"=>0, "errors"=>[]}, @result)
      assert u.mailchimp_synchronized?
    end

    should "skip already synchronized users" do
      all_users.each { |u| u.mailchimp_synchronized! }
      Timecop.travel(Time.zone.now+10.seconds)
      VCR.use_cassette('mailchimp_update_user') do
        @result = MAILCHIMP.export_users end
      assert_equal({}, @result)
    end

    end
  end

   private

    def create_users
      create_user_with_listing_with_photo
      create_user_with_listing_without_photo
      create_user_without_listing
      create_user_with_two_listings
    end

    def create_user_with_listing_with_photo
      @user_with_listing_with_photo = create_photo(create_listing(create_location(create_company(FactoryGirl.create(:user, :email => 'krajek6+1@gmail.com', :name => 'John Smith')))))
      listing = @user_with_listing_with_photo.listings.first
      listing.daily_price = nil
      listing.weekly_price = nil
      listing.monthly_price = nil
      listing.free = true
      listing.save!
      @user_with_listing_with_photo.reload
    end

    def create_user_with_listing_without_photo
      @user_with_listing_without_photo = create_listing(create_location(create_company(FactoryGirl.create(:user, :email => 'krajek6+2@gmail.com', :name => 'Maciej Krajowski')))) 
    end

    def create_user_with_two_listings
      @user_with_two_listings = create_listing(create_listing(create_location(create_company(FactoryGirl.create(:user, :email => 'krajek6+4@gmail.com', :name => 'Bob Bobman')))))
    end

    def create_user_without_listing
      @user_without_listing = FactoryGirl.create(:user, :email => 'krajek6+3@gmail.com', :name => 'James Jones')
    end
    
    def create_company(user)
      FactoryGirl.create(:company, :creator => user, :name => 'Company')
      user.reload
    end

    def create_location(user)
      FactoryGirl.create(:location, :company => user.companies.first, :street => 'Street')
      user.reload
    end

    def create_listing(user)
      FactoryGirl.create(:listing, :location => user.companies.first.locations.first, :photo_not_required => true, :photos_count_to_be_created => 0)
      user.reload
    end

    def create_photo(user)
      FactoryGirl.create(:photo, :listing => user.listings.first, :creator => user)
      user.reload
    end

    # stub urls containing dynamic id to make it work no matter if you invoke only this test, or all tests [ via rake ci for instance ]
    def stubs_urls
      Rails.application.routes.url_helpers.stubs(:verify_user_url).returns("http://example.com/users/verify/1/token")
      Rails.application.routes.url_helpers.stubs(:manage_location_listing_url).returns("http://example.com/manage/locations/1/listings/1")
      Rails.application.routes.url_helpers.stubs(:location_url).returns("http://example.com/manage/locations/1")
    end

   def all_users
     [@user_with_listing_with_photo, @user_with_listing_without_photo, @user_without_listing, @user_with_two_listings]
   end
end
