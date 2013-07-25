require 'test_helper'

class UserTest < ActiveSupport::TestCase

  include ApplicationHelper

  should have_many(:industries)

  context "validations" do
    context "when no country name provided" do

      context "when country name required" do
        should "be valid" do
          user = FactoryGirl.build(:user_without_country_name)
          assert user.save
        end
      end

      context "when country name not required" do
        should "be invalid" do
          user = FactoryGirl.create(:user_without_country_name)
          user.country_name_required = true
          assert_equal user.save, false
        end
      end

    end

  end

  should "have authentications" do
    @user = User.new
    @user.authentications << Authentication.new
    @user.authentications << Authentication.new

    assert @user.authentications
  end

  should "be valid even if its company is not valid" do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, :creator => @user)
    @company.name = nil
    @company.save(:validate => false)
    @user.reload
    assert @user.valid?
  end

  should "know what authentication providers it is linked to" do
    @user = User.find(16)
    @user.authentications.find_or_create_by_provider("exists").tap do |a|
      a.uid = 16
    end.save!
    assert @user.linked_to?("exists")
  end

  should "know what authentication providers it isn't linked to" do
    @user = User.find(16)
    refute @user.linked_to?("doesntexist")
  end

  should "it has reservations" do
    @user = User.new
    @user.reservations << Reservation.new
    @user.reservations << Reservation.new

    assert @user.reservations
  end

  should "have full email address" do
    @user = User.new(name: "Hulk Hogan", email: "hulk@desksnear.me")

    assert_equal "Hulk Hogan <hulk@desksnear.me>", @user.full_email
  end

  should "have avatar if user did not upload it" do
    @user = FactoryGirl.create(:user)
    assert_equal false, @user.avatar_provided?
  end

  should "have avatar if user uploaded it" do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.expand_path("../../assets/foobear.jpeg", __FILE__))
    @user.save!
    assert @user.avatar_provided?
  end

  should "save user even when avatar image does not have extension" do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.expand_path("../../assets/image_no_extension", __FILE__))
    @user.save!
    assert @user.avatar_provided?
  end

  should "save avatar from remote url" do
    stub_image_url("http://www.example.com/image.jpg")
    @user = FactoryGirl.create(:user)
    @user.remote_avatar_url = "http://www.example.com/image.jpg"
    begin
      @user.save!
    rescue
    end
    assert @user.avatar_provided?
  end

  should "not save afatar from remote url if save is not invoked" do
    stub_image_url("http://www.example.com/image.jpg")
    @user = FactoryGirl.create(:user)
    @user.remote_avatar_url = "http://www.example.com/image.jpg"
    @user.reload
    assert @user.avatar_provided?
  end

  context '#full_mobile_number' do
    setup do
      @nz = Country.find('New Zealand')
    end

    should 'prefix with international calling code' do
      user = User.new
      user.country_name = @nz.name
      user.mobile_number = '123456'
      assert_equal '+64123456', user.full_mobile_number
    end

    should 'not include 0 prefix from base number' do
      user = User.new
      user.country_name = @nz.name
      user.mobile_number = '0123456'
      assert_equal '+64123456', user.full_mobile_number
    end
  end

  context "#has_phone_and_country?" do
    context "phone and country are present" do
      should "return true" do
        user = User.new
        user.country_name = "United States"
        user.phone = "1234"
        assert user.has_phone_and_country?
      end
    end

    context "phone is missing" do
      should "return false" do
        user = User.new
        user.country_name = "United States"
        assert_equal user.has_phone_and_country?, false
      end
    end

    context "phone is missing" do
      should "return true" do
        user = User.new
        user.phone = "1234"
        assert_equal user.has_phone_and_country?, false
      end
    end
  end

  context "#phone_or_country_was_changed?" do
      context "previous value was blank" do
        context "phone was changed" do
          should "return true" do
            user = User.new
            user.phone = 456
            assert user.phone_or_country_was_changed?
          end
        end

        context "country_name was changed" do
          should "return true" do
            user = User.new
            user.country_name = "Slovenia"
            assert user.phone_or_country_was_changed?
          end
        end
      end

      context "previous value wasn't blank" do
        context "phone was changed" do
          should "return false" do
            user = FactoryGirl.create(:user)
            user.phone = 456
            assert !user.phone_or_country_was_changed?
          end
        end

        context "country_name was changed" do
          should "return false" do
            user = FactoryGirl.create(:user)
            user.country_name = "Slovenia"
            assert !user.phone_or_country_was_changed?
          end
        end
      end
  end

  context "mailchimp" do

    should "not be exported without synchronize timestamp" do
      @user = FactoryGirl.create(:user)
      assert !@user.mailchimp_exported?
    end

    should "not exported with synchronize timestamp" do
      @user = FactoryGirl.create(:user)
      @user.mailchimp_synchronized_at = Time.zone.now
      assert @user.mailchimp_exported?
    end

    context "synchronize" do

      setup do
        @user = FactoryGirl.create(:user)
        @user.mailchimp_synchronized!
      end

      teardown do
        Timecop.return
      end

      context "user CRUD" do

        should "be synchronized if no change happened since last synchronize" do
          assert @user.mailchimp_synchronized?
        end

        should "not be synchronized if change to user happened since last synchronize" do
          Timecop.travel(Time.zone.now+10.seconds)
          @user.name = 'John Smith'
          @user.save!
          assert !@user.mailchimp_synchronized?
        end

        should "be synchronized if multiple changes happens to user but none after last synchronize" do
          Timecop.travel(Time.zone.now+10.seconds)
          @user.name = 'John Smith'
          @user.save!
          Timecop.travel(Time.zone.now+10.seconds)
          @user.mailchimp_synchronized!
          assert @user.mailchimp_synchronized?
        end

        context "company CRUD" do

          setup do
            @company = FactoryGirl.create(:company, :creator => @user)
            @user.mailchimp_synchronized!
            Timecop.travel(Time.zone.now+10.seconds)
          end

          should "not be synchronized if change to company happened since last synchronize" do
            @company.name = "New name"
            @company.save!
            assert !@user.mailchimp_synchronized?
          end

          should "not be synchronized if user destroyes company since last synchronize" do
            @company.destroy!
            assert !@user.mailchimp_synchronized?
          end


          context "location CRUD" do

            setup do 
              @location = FactoryGirl.create(:location, :company => @company)
              @user.mailchimp_synchronized!
              Timecop.travel(Time.zone.now+10.seconds)
            end

            should "not be synchronized if change to location happened since last synchronize" do
              @location.address = '1100 Rock and Roll Boulevard'
              @location.latitude = "41.508806"
              @location.longitude = "-81.69548"
              @location.save!
              assert !@user.mailchimp_synchronized?
            end

            should "not be synchronized if user creates new location since last synchronize" do
              @location = FactoryGirl.create(:location, :company => @company)
              assert !@user.mailchimp_synchronized?
            end

            should "not be synchronized if user destroyes location since last synchronize" do
              @location.destroy!
              assert !@user.mailchimp_synchronized?
            end

            context "listing CRUD" do

              setup do
                @listing = FactoryGirl.create(:listing, :location => @location)
                @user.mailchimp_synchronized!
                Timecop.travel(Time.zone.now+10.seconds)
              end

              should "not be synchronized if change to listing happened since last synchronize" do
                @listing.weekly_price = 10
                @listing.save!
                assert !@user.mailchimp_synchronized?
              end

              should "not be synchronized if user creates new listing since last synchronize" do
                @listing = FactoryGirl.create(:listing, :location => @location)
                assert !@user.mailchimp_synchronized?
              end

              should "not be synchronized if user destroyes listing since last synchronize" do
                @listing.destroy!
                assert !@user.mailchimp_synchronized?
              end

              context "photo CRUD" do

                setup do
                  @photo = FactoryGirl.create(:photo, :content => @listing)
                  @user.mailchimp_synchronized!
                  Timecop.travel(Time.zone.now+10.seconds)
                end

                should "be synchronized if change to photo happened since last synchronize" do
                  @photo.caption = "New caption"
                  @photo.save!
                  assert @user.mailchimp_synchronized?
                end

                should "not be synchronized if user creates new photo since last synchronize" do
                  @photo = FactoryGirl.create(:photo, :content => @listing)
                  assert !@user.mailchimp_synchronized?
                end

                should "not be synchronized if user destroyes photo since last synchronize" do
                  @photo.destroy!
                  assert !@user.mailchimp_synchronized?
                end
              end
            end
          end
        end
      end
    end

    context "has listing without price" do

      setup do
        @user = FactoryGirl.create(:user, :name => 'John Smith')
        @company = FactoryGirl.create(:company, :creator => @user)
        @location = FactoryGirl.create(:location, :company => @company)
        @location2 = FactoryGirl.create(:location, :company => @company)
        FactoryGirl.create(:listing, :location => @location, :daily_price_cents => 10)
        FactoryGirl.create(:listing, :location => @location, :daily_price_cents => 20)
      end

      should "has listing without price return false if all listings have price" do
        assert !@user.has_listing_without_price?
      end

      should "be false if location has only one listing without prices" do
        FactoryGirl.create(:listing, :location => @location2, :daily_price_cents => nil, :weekly_price_cents => nil, :monthly_price_cents => nil, :free => true)
        assert @user.has_listing_without_price?
      end

      should "be false if location has many listing, and at least one is without price" do
        FactoryGirl.create(:listing, :location => @location, :daily_price_cents => nil, :weekly_price_cents => nil, :monthly_price_cents => nil, :free => true)
        assert @user.has_listing_without_price?
      end

    end

  end

end

