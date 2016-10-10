require 'test_helper'

class Authentication::TwitterProviderTest < ActiveSupport::TestCase
  context 'Having a Twitter provider' do
    setup do
      user = FactoryGirl.build(:user)
      @twitter_provider = Authentication::TwitterProvider.new(user: user,
                                                              token: 'abcd',
                                                              secret: 'dcba')
    end

    should 'return info object' do
      raw = OpenStruct.new(id: 'dnm', username: 'desksnearme', name: 'Desks Near Me')
      raw.stubs(:profile_image_url).returns('https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg')
      Twitter::REST::Client.any_instance.stubs(:user).once.returns(raw)

      assert_equal 'dnm', @twitter_provider.info.uid
      assert_equal 'desksnearme', @twitter_provider.info.username
      assert_equal 'Desks Near Me', @twitter_provider.info.name
      assert_nil @twitter_provider.info.profile_url
      assert_nil @twitter_provider.info.website_url
      assert_equal 'https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg', @twitter_provider.info.image_url

      assert_nil @twitter_provider.info.to_hash['uid']
      assert_equal 'desksnearme', @twitter_provider.info.to_hash['nickname']
      assert_equal 'Desks Near Me', @twitter_provider.info.to_hash['name']
      assert_nil @twitter_provider.info.to_hash['urls']['Twitter']
      assert_nil @twitter_provider.info.to_hash['urls']['Website']
      assert_equal 'https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg', @twitter_provider.info.to_hash['image']
    end

    should 'return friend_ids' do
      Twitter::REST::Client.any_instance.stubs(:friend_ids).once.returns(%w(1 2))

      assert_equal %w(1 2), @twitter_provider.friend_ids
    end

    context 'when token is invalid' do
      setup do
        Authentication::TwitterProvider.any_instance.stubs(:connection).raises(Twitter::Error::Unauthorized)
      end

      should 'rescue and re-raise error when calling friend_ids' do
        assert_raise Authentication::InvalidToken do
          @twitter_provider.friend_ids
        end
      end

      should 'rescue and re-raise error when calling info' do
        assert_raise Authentication::InvalidToken do
          @twitter_provider.info
        end
      end
    end

    should 'rescue and ignore TooManyRequests error' do
      @twitter_client_stub = mock
      @twitter_client_stub.stubs(:friend_ids).raises(Twitter::Error::TooManyRequests)
      @twitter_provider.stubs(:connection).returns(@twitter_client_stub)

      assert_nothing_raised do
        @twitter_provider.friend_ids
      end
    end
  end
end
