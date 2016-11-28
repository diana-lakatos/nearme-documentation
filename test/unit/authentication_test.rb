require 'test_helper'

class AuthenticationTest < ActiveSupport::TestCase
  should validate_presence_of(:provider)
  should validate_presence_of(:uid)

  should validate_uniqueness_of(:provider).scoped_to(:user_id)
  should validate_uniqueness_of(:uid).scoped_to(:provider)

  setup do
    @user = FactoryGirl.build(:user, password: nil, instance_id: Instance.first.id)
    @user.save!(validate: false)

    @valid_params = { provider: 'desksnearme',
                      uid: '123456789',
                      token: 'abcd1234',
                      user_id: @user.id }
  end

  context '#connections' do
    should 'return connection count' do
      friend = FactoryGirl.create(:user)
      user_auth = @user.authentications.create(FactoryGirl.attributes_for(:authentication))
      friend_auth = friend.authentications.create(FactoryGirl.attributes_for(:authentication))
      @user.add_friend(friend, user_auth)

      refute_equal user_auth.connections, friend_auth.connections
      assert_equal 1, user_auth.connections.count
      assert_equal 1, friend_auth.connections.count
    end
  end

  context '#update_info' do
    setup do
      @authentication = FactoryGirl.create(:authentication)
    end

    should 'be performed if not done yet' do
      UpdateInfoJob.expects(:perform).once
      @authentication.update_info
    end

    should 'not be performed if already done' do
      @authentication.touch(:information_fetched)
      UpdateInfoJob.expects(:perform).never
      @authentication.update_info
    end
  end

  context 'social connection' do
    class Authentication::DesksnearmeProvider < Authentication::BaseProvider
      def initialize(_params)
      end
    end

    should 'call provider' do
      auth = Authentication.create(@valid_params)
      Authentication::DesksnearmeProvider.expects(:new_from_authentication).with(auth)
      auth.social_connection
    end

    should 'have provider for every available provider' do
      Authentication.available_providers.each do |provider|
        assert_nothing_raised do
          "Authentication::#{provider.downcase.capitalize}Provider".constantize
        end
      end
    end

    should 'be created for different user if authentication with the same provider and uid has been removed previously' do
      Authentication.create(@valid_params).destroy
      @valid_params[:user_id] = FactoryGirl.create(:user).id
      assert_nothing_raised do
        Authentication.create!(@valid_params)
      end
    end
  end

  should 'has a hash for info' do
    auth = Authentication.create(@valid_params)
    auth.info['thing'] = 'stuff'
    assert_equal 'stuff', auth.info['thing']
  end

  context '.with_valid_token' do
    should 'return Authentications with a valid access token' do
      auth = FactoryGirl.create(:authentication, token_expired: false, token_expires_at: 3.days.from_now)
      auth_expired = FactoryGirl.create(:authentication, token_expires_at: 1.week.ago)

      assert Authentication.with_valid_token.include?(auth)
      assert !Authentication.with_valid_token.include?(auth_expired)
    end
  end

  context '#can_be_deleted?' do
    should 'be deleted if user has not blank password and he has no other authentications' do
      auth = FactoryGirl.create(:user).authentications.create(@valid_params)
      auth.user.stubs(:has_password?).returns(true)
      assert auth.can_be_deleted?
    end

    should 'be deleted if user has blank password but he has other authentications' do
      auth = FactoryGirl.create(:user).authentications.create(@valid_params)
      auth.user.stubs(:has_password?).returns(false)
      auth.user.authentications << Authentication.create
      assert auth.can_be_deleted?
    end

    should 'be deleted if user has not blank password and he has other authentications' do
      auth = FactoryGirl.create(:user).authentications.create(@valid_params)
      auth.user.stubs(:has_password?).returns(true)
      auth.user.authentications << Authentication.create
      assert auth.can_be_deleted?
    end
  end
end
