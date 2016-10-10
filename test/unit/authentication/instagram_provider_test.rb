require 'test_helper'

class Authentication::InstagramProviderTest < ActiveSupport::TestCase
  context 'Having a Instagram provider' do
    setup do
      user = FactoryGirl.build(:user)
      @instagram_provider = Authentication::InstagramProvider.new(user: user,
                                                                  token: 'abcd',
                                                                  secret: 'dcba')
    end

    should 'return info object' do
      raw = OpenStruct.new(id: 'dnm', username: 'desksnearme', full_name: 'Desks Near Me', profile_picture: 'https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg')
      Instagram::Client.any_instance.stubs(:user).once.returns(raw)

      assert_equal 'dnm', @instagram_provider.info.uid
      assert_equal 'desksnearme', @instagram_provider.info.username
      assert_equal 'Desks Near Me', @instagram_provider.info.name
      assert_equal 'http://instagram.com/desksnearme', @instagram_provider.info.profile_url
      assert_nil @instagram_provider.info.website_url
      assert_equal 'https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg', @instagram_provider.info.image_url

      assert_nil @instagram_provider.info.to_hash['uid']
      assert_equal 'desksnearme', @instagram_provider.info.to_hash['nickname']
      assert_equal 'Desks Near Me', @instagram_provider.info.to_hash['name']
      assert_equal 'http://instagram.com/desksnearme', @instagram_provider.info.to_hash['urls']['Instagram']
      assert_nil @instagram_provider.info.to_hash['urls']['Website']
      assert_equal 'https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg', @instagram_provider.info.to_hash['image']
    end

    should 'return friend_ids' do
      connections = [stub(id: '1'), stub(id: '2')]
      Instagram::Client.any_instance.stubs(:user_follows).once.returns(connections)

      assert_equal %w(1 2), @instagram_provider.friend_ids
    end

    context 'when token is invalid' do
      setup do
        @instagram_provider.stubs(:connection).once.raises(Instagram::BadRequest)
      end

      should 'rescue and re-raise error when calling friend_ids' do
        assert_raise Authentication::InvalidToken do
          @instagram_provider.friend_ids
        end
      end

      should 'rescue and re-raise error when calling info' do
        assert_raise Authentication::InvalidToken do
          @instagram_provider.info
        end
      end
    end
  end
end
