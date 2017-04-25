# frozen_string_literal: true
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ApplicationHelper

  def after_teardown
    CacheExpiration.rebuild_cache_for_custom_attributes
    super
  end

  setup do
    stub_active_merchant_interaction
  end

  context 'instance owner method' do
    should 'return true if the user is an instance owner' do
      @instance_owner = FactoryGirl.create(:instance_admin)
      assert @instance_owner.user.is_instance_owner?
    end
  end

  context '#social_connections' do
    should 'be empty for new user' do
      user = FactoryGirl.build(:user)
      assert_equal [], user.social_connections
    end

    should 'return provider and count for existing connections' do
      user = FactoryGirl.create(:user)
      friend = FactoryGirl.create(:user)
      auth = FactoryGirl.create(:authentication, provider: 'facebook')
      user.authentications << auth
      user.add_friend(friend, auth)
      connections = user.social_connections
      connection = connections.first
      assert_equal 1, connections.length
      assert_equal 'facebook', connection.provider
      assert_equal 1, connection.connections_count
    end
  end

  context '#without' do
    should 'handle single user' do
      user = FactoryGirl.create(:user)
      count = User.count
      assert_equal count - 1, User.without(user).count
    end

    should 'handle collection' do
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

    should 'raise for invalid auth' do
      auth = FactoryGirl.create(:authentication)
      assert_raise(ArgumentError) { @jimmy.add_friend(@joe, auth) }
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
      @listing = FactoryGirl.create(:transactable)
    end

    context 'visited_listing' do
      should 'xxxfind only users with confirmed past reservation for listing in friends' do
        FactoryGirl.create(:reservation, state: 'confirmed')

        4.times { @me.add_friend(FactoryGirl.create(:user)) }

        friends_with_visit = @me.friends.first(2)
        @me.friends.last.orders << FactoryGirl.create(:future_confirmed_reservation, date: Date.tomorrow)
        friends_with_visit.each { |f| FactoryGirl.create(:past_reservation, transactable: @listing, user: f) }

        assert_equal friends_with_visit.sort, @me.friends.visited_listing(@listing).to_a.sort
      end
    end

    context 'hosts_of_listing' do
      should 'find host of listing in friends' do
        friend1 = FactoryGirl.create(:user)
        @listing.location.update_attribute(:administrator_id, friend1.id)
        @listing.reload
        friend2 = FactoryGirl.create(:user)
        @me.add_friends([friend1, friend2])

        assert_equal [friend1].sort, @me.friends.hosts_of_listing(@listing).sort
      end
    end

    context 'friends_know_host_of' do
      should 'find users knows host' do
        2.times { @me.add_friend(FactoryGirl.create(:user)) }
        @friend = FactoryGirl.create(:user)

        @me.add_friend(@friend)

        @listing = FactoryGirl.create(:transactable)
        host = FactoryGirl.create(:user)
        @listing.location.update_attribute(:administrator_id, host.id)
        @listing.reload

        @friend.add_friend(host)

        @me.reload
        assert_equal [@friend], @me.friends_know_host_of(@listing)
      end
    end

    context 'mutual_friends_of' do
      should 'find users with friend that visited listing' do
        @friend = FactoryGirl.create(:user)
        @me.add_friend(@friend)
        mutual_friends = []
        4.times { mutual_friends << FactoryGirl.create(:user); @friend.add_friend(mutual_friends.last) }

        mutual_friends_with_visit = @friend.friends.without(@me).first(2)
        @friend.friends.last.orders << FactoryGirl.create(:future_confirmed_reservation, date: Date.tomorrow)
        mutual_friends_with_visit.each { |f| FactoryGirl.create(:past_reservation, transactable: @listing, user: f) }

        result = User.mutual_friends_of(@me).visited_listing(@listing)
        assert_equal mutual_friends_with_visit.sort, result.sort
        assert_equal [@friend], result.collect(&:mutual_friendship_source).uniq
      end
    end
  end

  context 'validations' do
    context 'when country name provided' do
      should 'have iso code from country name' do
        PlatformContext.current.instance.stubs(:skip_company?).returns(true)
        FactoryGirl.create(:country_pl) unless Country.find_by(iso: 'PL')
        user = FactoryGirl.build(:user_without_country_name, country_name: 'Poland', current_address: nil)
        assert_equal 'PL', user.iso_country_code
      end
    end

    context 'when no country name provided' do
      context 'when country name not required' do
        should 'be valid' do
          user = FactoryGirl.build(:user_without_country_name)
          assert user.valid?
        end
      end

      context 'when wrong phone numbers provided' do
        setup do
          @user = FactoryGirl.build(:user)
          @user.get_default_profile
        end

        should 'be invalid with wrong phone' do
          @user.phone = '3423jhjhg432'
          refute @user.valid?
        end

        should 'be invalid with wrong mobile number' do
          @user.mobile_number = '3423jhjhg432'
          refute @user.valid?
        end

        should 'be valid with empty numbers' do
          @user.mobile_number = nil
          @user.phone = nil
          assert @user.valid?
        end
      end
    end

    context 'approval_requests' do
      setup do
        @user = FactoryGirl.build(:user)
        @user.approval_requests = []
      end

      context 'instance does not require verification' do
        should 'be valid without approval_requests' do
          assert @user.valid?
        end

        should 'be trusted even without approval_requests' do
          assert @user.is_trusted?
        end
      end

      context 'instance does require verification' do
        setup do
          FactoryGirl.create(:approval_request_template)
          @approval_request = FactoryGirl.build(:approval_request)
          @user.save!
          @user.update! created_at: 1.minute.from_now
        end

        should 'not be trusted without approval_requests' do
          refute @user.is_trusted?
        end

        should 'not be trusted with approval_request that is uploaded' do
          @user.approval_requests << @approval_request
          @user.save!
          refute @user.is_trusted?
        end

        should 'not be trusted with approval_request that is rejected' do
          @user.approval_requests << @approval_request
          @user.save!
          @approval_request.reject!
          refute @user.is_trusted?
        end

        should 'not be trusted with approval_request that is questioned' do
          @user.approval_requests << @approval_request
          @user.save!
          @approval_request.question!
          refute @user.is_trusted?
        end

        should 'be trusted with approval_request that is accepted' do
          @user.approval_requests << @approval_request
          @user.save!
          @approval_request.accept
          assert @user.is_trusted?
        end
      end
    end

    context 'when special requirements per instance' do
      should 'be valid without middle_name if has not been peristed yet' do
        @user = FactoryGirl.build(:user, middle_name: nil)
        @user.custom_validation = true
        assert @user.valid?
      end
    end
  end

  context 'name' do
    setup do
      @user = FactoryGirl.create(:user, name: 'jimmy falcon')
    end

    should 'not have capitalized name' do
      assert_equal 'jimmy falcon', @user.name
    end

    should 'not have capitalized first name' do
      assert_equal 'jimmy', @user.first_name
    end
  end

  context 'reservations' do
    setup do
      @user = FactoryGirl.create(:user)
    end

    should 'find rejected reservations' do
      FactoryGirl.create(:reservation, user: @user, state: 'unconfirmed')
      FactoryGirl.create(:reservation, user: @user, state: 'rejected')
      assert_equal 1, @user.rejected_reservations.count
    end

    should 'find confirmed reservations' do
      FactoryGirl.create(:reservation, user: @user, state: 'unconfirmed')
      FactoryGirl.create(:reservation, user: @user, state: 'confirmed')
      assert_equal 1, @user.confirmed_reservations.count
    end

    should 'find expired reservations' do
      FactoryGirl.create(:reservation, user: @user, state: 'unconfirmed')
      FactoryGirl.create(:reservation, user: @user, state: 'expired')
      assert_equal 1, @user.expired_reservations.count
    end

    should 'find cancelled reservations' do
      FactoryGirl.create(:reservation, user: @user, state: 'unconfirmed')
      FactoryGirl.create(:reservation, user: @user, state: 'cancelled_by_guest')
      FactoryGirl.create(:reservation, user: @user, state: 'cancelled_by_host')
      assert_equal 2, @user.cancelled_reservations.count
    end
  end

  should 'have authentications' do
    @user = FactoryGirl.create(:user)
    @user.authentications << FactoryGirl.build(:authentication)
    @user.authentications << FactoryGirl.build(:authentication_linkedin)
    @user.save

    assert @user.reload.authentications

    assert_nil @user.facebook_url
    assert_equal 'http://twitter.com/someone', @user.twitter_url
    assert_equal 'http://linkedin.com/someone', @user.linkedin_url
    assert_nil @user.instagram_url
  end

  should 'be valid even if its company is not valid' do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    @company.name = nil
    @company.save(validate: false)
    @user.reload
    assert @user.valid?
  end

  should 'know what authentication providers it is linked to' do
    @user = FactoryGirl.create(:user)
    @user.authentications.where(provider: 'exists').first_or_create.tap do |a|
      a.uid = @user.id
      a.token = 'abcd'
    end.save!
    assert @user.linked_to?('exists')
  end

  should "know what authentication providers it isn't linked to" do
    @user = FactoryGirl.create(:user)
    refute @user.linked_to?('doesntexist')
  end

  should 'it has reservations' do
    @user = User.new
    @user.orders.reservations << Reservation.new
    @user.orders.reservations << Reservation.new

    assert @user.orders.reservations
  end

  should 'allow users to use the same email across marketplaces' do
    @user = FactoryGirl.create(:user, email: 'hulk@desksnear.me')
    assert_raise ActiveRecord::RecordInvalid do
      FactoryGirl.create(:user, email: 'hulk@desksnear.me')
    end
    PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
    assert_nothing_raised do
      FactoryGirl.create(:user, email: 'hulk@desksnear.me')
    end
  end

  should 'allow users to use the same email if external id is different' do
    @user = FactoryGirl.create(:user, email: 'hulk@desksnear.me', external_id: 'something')
    assert_raise ActiveRecord::RecordInvalid do
      FactoryGirl.create(:user, email: 'hulk@desksnear.me', external_id: 'something')
    end
    assert_nothing_raised do
      FactoryGirl.create(:user, email: 'hulk@desksnear.me', external_id: 'different')
    end
  end

  should 'have full email address' do
    @user = User.new(name: 'Hulk Hogan', email: 'hulk@desksnear.me')

    assert_equal 'Hulk Hogan <hulk@desksnear.me>', @user.full_email
  end

  should 'not have avatar if user did not upload it' do
    @user = FactoryGirl.create(:user)
    @user.remove_avatar!
    @user.save!

    assert !@user.avatar.file.present?
  end

  should 'have avatar if user uploaded it' do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.expand_path('../../assets/foobear.jpeg', __FILE__))
    @user.avatar_versions_generated_at = Time.zone.now
    @user.save!
    assert @user.avatar.file.present?
  end

  should 'allow to download image from linkedin which do not have extension' do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.expand_path('../../assets/image_no_extension', __FILE__))
    @user.avatar_versions_generated_at = Time.zone.now
    assert @user.valid?, @user.errors.full_messages.join(', ')
  end

  should 'have mailer unsubscriptions' do
    @user = FactoryGirl.create(:user)
    @user.unsubscribe('recurring_mailer/analytics')

    assert @user.unsubscribed?('recurring_mailer/analytics')
  end

  context '#full_mobile_number' do
    setup do
      @nz = FactoryGirl.create(:country_nz)
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

  context '#has_phone_and_country?' do
    context 'phone and country are present' do
      should 'return true' do
        user = User.new
        user.country_name = 'United States'
        user.phone = '1234'
        assert user.has_phone_and_country?
      end
    end

    context 'phone is missing' do
      should 'return false' do
        user = User.new
        user.country_name = 'United States'
        assert_equal user.has_phone_and_country?, false
      end
    end

    context 'phone is missing' do
      should 'return true' do
        user = User.new
        user.phone = '1234'
        assert_equal user.has_phone_and_country?, false
      end
    end
  end

  context '#phone_or_country_was_changed?' do
    context 'previous value was blank' do
      context 'phone was changed' do
        should 'return true' do
          user = User.new
          user.phone = 456
          assert user.phone_or_country_was_changed?
        end
      end

      context 'country_name was changed' do
        should 'return true' do
          user = User.new
          user.country_name = 'Slovenia'
          assert user.phone_or_country_was_changed?
        end
      end
    end

    context "previous value wasn't blank" do
      context 'phone was changed' do
        should 'return false' do
          user = FactoryGirl.create(:user)
          user.phone = 456
          assert !user.phone_or_country_was_changed?
        end
      end

      context 'country_name was changed' do
        should 'return false' do
          user = FactoryGirl.create(:user)

          user.country_name = 'Slovenia'
          assert !user.phone_or_country_was_changed?
        end
      end
    end

    context 'full_mobile_number_updated?' do
      should 'be true if mobile phone was updated' do
        user = FactoryGirl.create(:user)
        user.mobile_number = '31232132'
        assert user.full_mobile_number_updated?
      end

      should 'be true if country was updated' do
        user = FactoryGirl.create(:user)
        user.country_name = 'Poland'
        assert user.full_mobile_number_updated?
      end

      should 'be false if phone was updated' do
        user = FactoryGirl.create(:user)
        user.phone = '31232132'
        assert !user.full_mobile_number_updated?
      end
    end

    context 'update_notified_mobile_number_flag' do
      setup do
        @user = FactoryGirl.create(:user)
        @user.notified_about_mobile_number_issue_at = Time.zone.now
      end

      should 'be false if phone or country has changed' do
        @user.stubs(:full_mobile_number_updated?).returns(true)
        @user.save!
        assert_nil @user.notified_about_mobile_number_issue_at
      end

      should 'not update timestamp when saved' do
        travel_to Time.zone.now do
          @user.stubs(:full_mobile_number_updated?).returns(false)
          notified_at = Time.zone.now - 5.days
          @user.notified_about_mobile_number_issue_at = notified_at
          @user.save!
          assert_equal notified_at, @user.notified_about_mobile_number_issue_at
        end
      end
    end
  end

  context 'notify about invalid mobile phone' do
    setup do
      FactoryGirl.create(:instance)
      @user = FactoryGirl.create(:user)
      Utils::DefaultAlertsCreator::SignUpCreator.new.create_notify_of_wrong_phone_number_email!
    end

    should 'notify user about invalid phone via email' do
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
      @user.notify_about_wrong_phone_number
      sent_mail = ActionMailer::Base.deliveries.last
      assert_equal [@user.email], sent_mail.to

      assert sent_mail.html_part.body.encoded.include?('1.888.998.3375'), 'Body did not include expected phone number 1.888.998.3375'
      assert sent_mail.html_part.body.encoded =~ /<a class="btn" href="https:\/\/custom.domain.com\/users\/edit\?#{TemporaryTokenAuthenticatable::PARAMETER_NAME}=.+" style=".+">Go to My account<\/a>/, "Body did not include expected link to edit profile #{TemporaryTokenAuthenticatable::PARAMETER_NAME}: #{"<a class='btn' href='https:\/\/custom.domain.com\/users\/edit\?#{TemporaryTokenAuthenticatable::PARAMETER_NAME}=.+' style='.+'"} in #{sent_mail.html_part.body}"
    end

    should 'not spam user' do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        5.times do
          @user.notify_about_wrong_phone_number
        end
      end
    end

    should 'update timestamp of notification' do
      travel_to Time.zone.now do
        @user.notify_about_wrong_phone_number
        assert_equal Time.zone.now.to_a, @user.notified_about_mobile_number_issue_at.to_a
      end
    end
  end

  context 'no orphaned childs' do
    context 'user is the only owner of company' do
      should 'destroy company' do
        @listing = FactoryGirl.create(:transactable)
        @location = @listing.location
        @company = @location.company
        @listing.creator.destroy
        assert @listing.reload.deleted?
        assert @location.reload.deleted?
        assert @company.reload.deleted?
      end
    end

    context 'reservations' do
      setup do
        @user = FactoryGirl.create(:user)
      end

      should 'cancel any pending unconfirmed reservations' do
        # We need to stub void request on reservation

        @reservation = FactoryGirl.create(:unconfirmed_reservation, user: @user)
        @user.destroy
        assert @reservation.reload.cancelled_by_guest?
        assert @reservation.payment.voided?
      end

      should 'cancel any pending reservations' do
        @reservation = FactoryGirl.create(:confirmed_reservation, user: @user)
        @user.destroy
        refute @reservation.reload.cancelled_by_guest?
        assert @reservation.confirmed?
      end
    end
  end

  context '#listings_in_near' do
    setup do
      @user = FactoryGirl.create(:user)
      @other_instance = FactoryGirl.create(:instance)
    end

    should 'return empty array if no platform_context set' do
      assert_equal [], @user.listings_in_near
    end

    should 'return listings from current platform_context instance' do
      # user was last geolocated in Auckland
      @user.last_geolocated_location_latitude = -36.858675
      @user.last_geolocated_location_longitude = 174.777303
      @user.save!

      listing_current_instance = FactoryGirl.create(:listing_in_auckland)

      listing_other_instance = FactoryGirl.create(:listing_in_auckland)
      listing_other_instance.update_attribute(:instance_id, @other_instance.id)

      assert_equal [listing_current_instance], @user.listings_in_near
    end

    should 'not return listings from cancelled/expired/rejected reservations' do
      # user was last geolocated in Auckland
      @user.last_geolocated_location_latitude = -36.858675
      @user.last_geolocated_location_longitude = 174.777303
      @user.save!
      listing_first = FactoryGirl.create(:listing_in_auckland)
      listing_second = FactoryGirl.create(:listing_in_auckland)
      reservation = FactoryGirl.create(:rejected_reservation, transactable: listing_first, user: @user)
      assert_equal [listing_second], @user.listings_in_near(3, 100, true)
    end
  end

  context 'recovering user with all objects' do
    should 'recover all objects' do
      setup_user_with_all_objects
      @user.destroy
      @objects.each do |object|
        assert object.reload.paranoia_destroyed?, "#{object.class.name} was expected to be deleted via dependent => destroy but wasn't"
      end
      @user.restore(recursive: true)
      @objects.each do |object|
        refute object.reload.paranoia_destroyed?, "#{object.class.name} was expected to be restored, but is still deleted"
      end
    end
  end

  context 'accepts sms' do
    setup do
      @user = FactoryGirl.create(:user_with_sms_notifications_enabled)
    end

    should 'not accept sms if no mobile phone' do
      @user.mobile_number = nil
      refute @user.accepts_sms?
    end

    should 'not accept sms if sms notifications are not enabled' do
      @user.sms_notifications_enabled = false
      refute @user.accepts_sms?
    end

    should 'not accept sms with specific type if this type of sms is disabled by user' do
      @user.sms_preferences = {}
      refute @user.accepts_sms_with_type?(:new_reservation)
    end

    should 'accept sms with specific type if this type of sms is enabled by user' do
      @user.sms_preferences = { 'new_reservation' => '1' }
      assert @user.accepts_sms_with_type?(:new_reservation)
    end
  end

  context 'metadata' do
    context 'populate_instance_admins_metadata' do
      setup do
        @instance_admin = FactoryGirl.create(:instance_admin)
        @user = @instance_admin.user
      end

      should 'populate correct instance_admin hash across instances' do
        PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
        @random_instance_admin = FactoryGirl.create(:instance_admin)
        PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
        @other_instance_admin = FactoryGirl.create(:instance_admin, user: @user)
        @user.expects(:update_instance_metadata).with(instance_admins_metadata: 'analytics')
        @user.populate_instance_admins_metadata!
      end
    end
  end

  context 'custom attributes' do
    setup do
      @type = InstanceProfileType.default.first
      @custom_attribute = FactoryGirl.create(:custom_attribute, name: 'custom_profile_attr', label: 'Custom Profile Attr', target: @type, attribute_type: 'string')
      @user = FactoryGirl.create(:user, instance_profile_type: @type)
    end

    should 'be able to set value' do
      assert_nothing_raised do
        @user.default_profile.properties.custom_profile_attr = 'hello'
        assert_equal 'hello', @user.properties.custom_profile_attr
      end
    end
  end

  context 'custom uniqueness validation' do
    should 'allow to create new account with email that belongs to user in other marketplace' do
      @other_user = FactoryGirl.create(:user)
      @other_user.update_column(:instance_id, PlatformContext.current.instance.id + 1)
      assert_nothing_raised do
        FactoryGirl.create(:user, email: @other_user.email)
      end
    end

    should 'not allow to create new account if other user exists with this email in this marketplace' do
      @user = FactoryGirl.create(:user)
      assert_raise ActiveRecord::RecordInvalid do
        FactoryGirl.create(:user, email: @user.email)
      end
    end

    should 'not allow to create new account without external id if other user exists with this email in this marketplace with external_id set' do
      @user = FactoryGirl.create(:user, external_id: 'something')
      assert_raise ActiveRecord::RecordInvalid do
        FactoryGirl.create(:user, email: @user.email)
      end
    end

    should 'allow to create new account with external id if other user exists with this email in this marketplace but with external_id set' do
      @user = FactoryGirl.create(:user, external_id: 'something')
      assert_nothing_raised do
        FactoryGirl.create(:user, email: @user.email, external_id: 'else')
      end
    end

    should 'allow to create new account with external id if other user exists with this email in this marketplace without external_id set' do
      @user = FactoryGirl.create(:user)
      assert_nothing_raised do
        FactoryGirl.create(:user, email: @user.email, external_id: 'else')
      end
    end

    should 'not allow to create new account with email that belongs to admin' do
      @admin = FactoryGirl.create(:admin)
      @admin.update_column(:instance_id, PlatformContext.current.instance.id + 1)
      assert_raise ActiveRecord::RecordInvalid do
        FactoryGirl.create(:user, email: @admin.email, external_id: 'something_else')
      end
    end
  end

  context '#all_transactables_count' do
    setup do
      @user = create(:user)
    end

    should 'set to 0 when creating a new user' do
      assert_equal 0, @user.all_transactables_count
    end

    should 'increase by 1 when creates a new project' do
      assert_difference '@user.reload.all_transactables_count' do
        project = create(:transactable, creator_id: @user.id)
      end
    end

    should 'not increase when changing project basic information' do
      counter = @user.all_transactables_count
      project = create(:transactable, creator_id: @user.id)
      assert_equal counter + 1, @user.reload.all_transactables_count

      project.name = 'Something else'
      project.save

      assert_equal counter + 1, @user.reload.all_transactables_count
    end

    should 'decrease counter if project is destroyed' do
      project = create(:transactable, creator_id: @user.id)
      counter = @user.reload.all_transactables_count
      project.destroy

      assert_equal counter - 1, @user.reload.all_transactables_count
    end

    should 'increase by 1 when start collaborating a project' do
      counter = @user.all_transactables_count
      collaborator = create(:transactable_collaborator, user: @user)
      assert_equal counter, @user.reload.all_transactables_count

      assert_difference '@user.reload.all_transactables_count' do
        collaborator.approved_by_owner_at = DateTime.now
        collaborator.approved_by_user_at = DateTime.now

        collaborator.save!
      end
    end

    should 'decrease counter if collaborator is destroyed' do
      collaborator = create(:transactable_collaborator, user: @user, approved_by_owner_at: DateTime.now, approved_by_user_at: DateTime.now)
      counter = @user.reload.all_transactables_count
      collaborator.destroy

      assert_equal counter - 1, @user.reload.all_transactables_count
    end
  end

  context '#ui_settings' do
    setup do
      @user = create(:user)
    end

    should 'set ui_settings to {} for a new user' do
      assert_equal '{}', @user.ui_settings
    end

    should 'return an empty hash for new user with get_all_ui_settings' do
      assert_equal Hash.new, @user.get_all_ui_settings
    end

    should 'return nil for unset setting' do
      assert_nil @user.get_ui_setting(:key)
    end

    should 'should persist a value when saving new ui setting' do
      @user.set_ui_setting('help-is-visible', 'true')
      assert_equal '{"help-is-visible":true}', @user.ui_settings
      assert @user.get_ui_setting('help-is-visible')
    end

    context 'name' do
      should 'last_name from name' do
        user = User.new(name: 'Jane Foo Doe')

        assert_equal 'Foo Doe', user.last_name
      end

      should 'first_name from name' do
        user = User.new(name: 'Jane Foo Doe')

        assert_equal 'Jane', user.first_name
      end

      should 'name' do
        user = User.new(name: 'Jane', last_name: 'Doe')
        assert_equal 'Jane', user.name
        assert_equal 'Doe', user.last_name
      end
    end
  end

  private

  def setup_user_with_all_objects
    @user = FactoryGirl.create(:user)
    @authentication = FactoryGirl.create(:authentication, user: @user)
    @company = FactoryGirl.create(:company, creator: @user)
    @location = FactoryGirl.create(:location, company_id: @company.id)
    @listing = FactoryGirl.create(:transactable, location: @location)
    @photo = FactoryGirl.create(:photo, listing: @listing, creator: @photo)
    @reservation = FactoryGirl.create(:reservation, user: @user, transactable: @listing)
    @reservation_period = @reservation.periods.first
    @payment = @reservation.payment
    @charge = FactoryGirl.create(:charge, payment: @payment)
    @payment_transfer = FactoryGirl.create(:payment_transfer, company_id: @company.id)
    FactoryGirl.build(:upload_obligation, level: UploadObligation::LEVELS[0], item: @listing)
    document_requirement = FactoryGirl.create(:document_requirement, item: @listing)
    @payment_document = FactoryGirl.create(:attachable_payment_document, attachable: @reservation, user: @user,
                                                                         payment_document_info: FactoryGirl.create(:payment_document_info, document_requirement: document_requirement))
    @objects = [@user, @authentication, @company,
                @location, @listing, @photo, @payment_document]
  end
end
