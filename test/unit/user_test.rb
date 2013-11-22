require 'test_helper'

class UserTest < ActiveSupport::TestCase

  include ApplicationHelper

  should have_many(:industries)

  context "#without" do
    should "handle single user" do
      user = FactoryGirl.create(:user)
      count = User.count
      assert_equal count - 1, User.without(user).count
    end

    should "handle collection" do
      3.times { FactoryGirl.create(:user) }
      users = User.first(2)
      count = User.count

      assert_equal count - 2, User.without(users).count
    end
  end

  context '#add_friend' do
    setup do
      @jimmy = FactoryGirl.create(:user)
      @joe = FactoryGirl.create(:user)
    end

    should 'creates two way relationship' do
      @jimmy.add_friend(@joe)

      assert_equal [@joe], @jimmy.friends
      assert_equal [@jimmy], @joe.friends
    end
  end

  context 'social scopes' do
    setup do
      @me = FactoryGirl.create(:user)
      @listing = FactoryGirl.create(:listing)
    end

    context 'visited_listing' do
      should 'find only users with confirmed past reservation for listing in friends' do
        FactoryGirl.create(:reservation, state: 'confirmed')

        4.times { @me.add_friend(FactoryGirl.create(:user)) }

        friends_with_visit = @me.friends.first(2)
        @me.friends.last.reservations << FactoryGirl.create(:future_reservation, state: 'confirmed', date: Date.tomorrow)
        friends_with_visit.each {|f| FactoryGirl.create(:past_reservation, state: 'confirmed', listing: @listing, user:f)}

        assert_equal friends_with_visit.sort, @me.friends.visited_listing(@listing).to_a.sort
      end
    end

    context 'hosts_of_listing' do
      should 'find host of listing in friends' do
        @listing.location.administrator = friend1 = FactoryGirl.create(:user)
        @listing.save!
        friend2 = FactoryGirl.create(:user)
        @me.add_friends(friend1, friend2)

        assert_equal [friend1].sort, @me.friends.hosts_of_listing(@listing).sort
      end
    end

    context 'know_host_of' do
      should 'find users knows host' do
        2.times { @me.add_friend(FactoryGirl.create(:user))}
        @friend = FactoryGirl.create(:user)

        @me.add_friend(@friend)

        @listing = FactoryGirl.create(:listing)
        @listing.location.administrator = host = FactoryGirl.create(:user)
        @listing.save!

        @friend.add_friend(host)

        assert_equal [@friend], @me.friends.know_host_of(@listing)
      end
    end

    context 'mutual_friends_of' do
      should 'find users with friend that visited listing' do
        @friend = FactoryGirl.create(:user)
        @me.add_friend(@friend)
        mutual_friends = []
        4.times { mutual_friends << FactoryGirl.create(:user); @friend.add_friend(mutual_friends.last) }

        mutual_friends_with_visit = @friend.friends.without(@me).first(2)
        @friend.friends.last.reservations << FactoryGirl.create(:future_reservation, state: 'confirmed', date: Date.tomorrow)
        mutual_friends_with_visit.each {|f| FactoryGirl.create(:past_reservation, state: 'confirmed', listing: @listing, user:f)}

        result = User.mutual_friends_of(@me).visited_listing(@listing)
        assert_equal mutual_friends_with_visit.sort, result.sort
        assert_equal [@friend], result.collect(&:mutual_friendship_source).uniq
      end
    end
  end

  context "validations" do
    context "when no country name provided" do

      context "when country name not required" do
        should "be valid" do
          user = FactoryGirl.build(:user_without_country_name)
          assert user.valid?
        end
      end

      context "when country name required" do
        should "be invalid" do
          user = FactoryGirl.build(:user_without_country_name, :country_name_required => true)
          assert_equal user.valid?, false
        end
      end

    end

  end

  context 'name' do
    setup do
      @user = FactoryGirl.create(:user, name: 'jimmy falcon')
    end

    should 'have capitalized name' do
      assert_equal "Jimmy Falcon", @user.name
    end

    should 'have capitalized first name' do
      assert_equal 'Jimmy', @user.first_name
    end

  end

  context 'reservations' do
    should 'find rejected reservations' do
      @user = FactoryGirl.create(:user, :reservations => [
        FactoryGirl.create(:reservation, :state => 'unconfirmed'),
        FactoryGirl.create(:reservation, :state => 'rejected') 
      ])
      assert_equal 1, @user.rejected_reservations.count
    end

    should 'find confirmed reservations' do
      @user = FactoryGirl.create(:user, :reservations => [
        FactoryGirl.create(:reservation, :state => 'unconfirmed'),
        FactoryGirl.create(:reservation, :state => 'confirmed') 
      ])
      assert_equal 1, @user.confirmed_reservations.count
    end

    should 'find expired reservations' do
      @user = FactoryGirl.create(:user, :reservations => [
        FactoryGirl.create(:reservation, :state => 'unconfirmed'),
        FactoryGirl.create(:reservation, :state => 'expired') 
      ])
      assert_equal 1, @user.expired_reservations.count
    end

    should 'find cancelled reservations' do
      @user = FactoryGirl.create(:user, :reservations => [
        FactoryGirl.create(:reservation, :state => 'unconfirmed'),
        FactoryGirl.create(:reservation, :state => 'cancelled_by_guest'),
        FactoryGirl.create(:reservation, :state => 'cancelled_by_host')
      ])
      assert_equal 2, @user.cancelled_reservations.count
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
    @user = FactoryGirl.create(:user)
    @user.authentications.find_or_create_by_provider("exists").tap do |a|
      a.uid = @user.id
      a.token = "abcd"
    end.save!
    assert @user.linked_to?("exists")
  end

  should "know what authentication providers it isn't linked to" do
    @user = FactoryGirl.create(:user)
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

  should "not have avatar if user did not upload it" do
    @user = FactoryGirl.create(:user)
    @user.remove_avatar!
    @user.save!

    assert !@user.avatar.any_url_exists?
  end

  should "have avatar if user uploaded it" do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.expand_path("../../assets/foobear.jpeg", __FILE__))
    @user.avatar_versions_generated_at = Time.zone.now
    @user.save!
    assert @user.avatar.any_url_exists?
  end

  should "allow to download image from linkedin which do not have extension" do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.expand_path("../../assets/image_no_extension", __FILE__))
    @user.avatar_versions_generated_at = Time.zone.now
    assert @user.save
  end

  should "have mailer unsubscriptions" do
    @user = FactoryGirl.create(:user)
    @user.unsubscribe('recurring_mailer/analytics')

    assert @user.unsubscribed?('recurring_mailer/analytics')
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

    context 'full_mobile_number_updated?' do

      should 'be true if mobile phone was updated' do
        user = FactoryGirl.create(:user)
        user.mobile_number = "31232132"
        assert user.full_mobile_number_updated?
      end

      should 'be true if country was updated' do
        user = FactoryGirl.create(:user)
        user.country_name = "Poland"
        assert user.full_mobile_number_updated?
      end

      should 'be false if phone was updated' do
        user = FactoryGirl.create(:user)
        user.phone = "31232132"
        assert !user.full_mobile_number_updated?
      end

    end

    context "update_notified_mobile_number_flag" do

      setup do
        @user = FactoryGirl.create(:user)
        @user.notified_about_mobile_number_issue_at = Time.zone.now
      end

      should "be false if phone or country has changed" do
        @user.stubs(:full_mobile_number_updated?).returns(true)
        @user.save!
        assert_nil @user.notified_about_mobile_number_issue_at
      end

      should "not update timestamp when saved" do
        Timecop.freeze(Time.zone.now)
        @user.stubs(:full_mobile_number_updated?).returns(false)
        notified_at = Time.zone.now - 5.days
        @user.notified_about_mobile_number_issue_at = notified_at
        @user.save!
        assert_equal notified_at, @user.notified_about_mobile_number_issue_at
        Timecop.return
      end
    end
  end

  context "notify about invalid mobile phone" do

    setup do
      stub_mixpanel
      FactoryGirl.create(:instance)
      @user = FactoryGirl.create(:user)
      @platform_context = PlatformContext.new
    end

    should 'notify user about invalid phone via email' do
      @user.notify_about_wrong_phone_number(@platform_context)
      sent_mail = ActionMailer::Base.deliveries.last
      assert_equal [@user.email], sent_mail.to

      assert sent_mail.html_part.body.encoded.include?('1.888.998.3375'), "Body did not include expected phone number 1.888.998.3375"
      assert sent_mail.html_part.body.encoded =~ /<a class="btn" href="http:\/\/example.com\/users\/edit\?token=.+" style=".+">Go to My account<\/a>/, "Body did not include expected link to edit profile"
    end

    should 'not spam user' do
      UserMailer.expects(:notify_about_wrong_phone_number).returns(mailer_stub).once
      5.times do 
        @user.notify_about_wrong_phone_number(@platform_context)
      end
    end

    should 'update timestamp of notification' do
      UserMailer.expects(:notify_about_wrong_phone_number).returns(mailer_stub).once
      Timecop.freeze(Time.zone.now)
      @user.notify_about_wrong_phone_number(@platform_context)
      assert_equal Time.zone.now.to_a, @user.notified_about_mobile_number_issue_at.to_a
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

  context 'no orphaned childs' do

    context 'user is the only owner of company' do

      should 'destroy company' do
        @listing = FactoryGirl.create(:listing)
        @location = @listing.location
        @company = @location.company
        @company.add_creator_to_company_users
        @company.save!
        @listing.creator.destroy
        assert @listing.reload.deleted?
        assert @location.reload.deleted?
        assert @company.reload.deleted?
      end

    end

    context 'company has multiple administrators' do

      setup do
        @listing = FactoryGirl.create(:listing)
        @user = @listing.creator
        @company = @listing.company
        @company.add_creator_to_company_users
        @company.save!
        @new_user = FactoryGirl.create(:user)
        CompanyUser.create(:user_id => @new_user.id, :company_id => @listing.company.id)
      end

      should 'not delete company and assign new creator' do
        @listing.creator.destroy
        @listing.reload
        assert_equal @new_user, @listing.creator
        refute @listing.deleted?
        refute @listing.location.deleted?
        refute @listing.location.company.deleted?
      end

      should 'not destroy company' do
        @new_user.destroy
        @listing.reload
        assert_equal @user, @listing.reload.creator
        refute @listing.deleted?
        refute @listing.location.deleted?
        refute @listing.location.company.deleted?
      end

    end

    should 'nullify administrator_id if user is administrator' do
      @user = FactoryGirl.create(:user)
      @location = FactoryGirl.create(:location, :creator => FactoryGirl.create(:user), :administrator => @user)
      CompanyUser.create(:user_id => @user.id, :company_id => @location.company.id)
      assert @location.administrator_id = @user.id
      @user.destroy
      assert_nil @location.reload.administrator_id
    end

  end

end

