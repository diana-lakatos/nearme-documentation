require 'test_helper'

class Authentication::FacebookProviderTest < ActiveSupport::TestCase
  context 'Having a Facebook provider' do
    setup do
      user = FactoryGirl.build(:user)
      @facebook_provider = Authentication::FacebookProvider.new(user: user,
                                                                token: 'abcd',
                                                                secret: 'dcba')
    end

    should 'return info object' do
      raw = { 'id' => 'dnm', 'username' => 'desksnearme', 'name' => 'Desks Near Me' }
      Koala::Facebook::API.any_instance.stubs(:get_object).with('me').once.returns(raw)

      assert_equal 'dnm', @facebook_provider.info.uid
      assert_equal 'desksnearme', @facebook_provider.info.username
      assert_equal 'Desks Near Me', @facebook_provider.info.name
      assert_nil @facebook_provider.info.profile_url
      assert_nil @facebook_provider.info.website_url
      assert_equal 'http://graph.facebook.com/dnm/picture?type=large', @facebook_provider.info.image_url

      assert_nil @facebook_provider.info.to_hash['uid']
      assert_equal 'desksnearme', @facebook_provider.info.to_hash['nickname']
      assert_equal 'Desks Near Me', @facebook_provider.info.to_hash['name']
      assert_nil @facebook_provider.info.to_hash['urls']['Facebook']
      assert_nil @facebook_provider.info.to_hash['urls']['Website']
      assert_equal 'http://graph.facebook.com/dnm/picture?type=large', @facebook_provider.info.to_hash['image']
    end

    should 'return friend_ids' do
      connections = [{ 'id' => 1 }, { 'id' => 2 }]
      Koala::Facebook::API.any_instance.stubs(:get_connections).once.returns(connections)

      assert_equal %w(1 2), @facebook_provider.friend_ids
    end

    context 'when token is invalid' do
      setup do
        @facebook_provider.stubs(:connection).once.raises(Koala::Facebook::AuthenticationError.new(500, nil))
      end

      should 'rescue and re-raise error when calling friend_ids' do
        assert_raise Authentication::InvalidToken do
          @facebook_provider.friend_ids
        end
      end

      should 'rescue and re-raise error when calling info' do
        assert_raise Authentication::InvalidToken do
          @facebook_provider.info
        end
      end
    end
  end
end
