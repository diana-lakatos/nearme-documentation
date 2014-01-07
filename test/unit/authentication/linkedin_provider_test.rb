require 'test_helper'

class Authentication::LinkedinProviderTest < ActiveSupport::TestCase

  context 'Having a Linkedin provider' do
    setup do
      user = FactoryGirl.build(:user)
      @linkedin_provider = Authentication::LinkedinProvider.new(user: user,
                                                               token: 'abcd',
                                                               secret: 'dcba')
    end

    should 'return info object' do
      raw = OpenStruct.new(id: 'dnm', first_name: 'Desks', last_name: 'Near Me', picture_url: 'https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg')
      LinkedIn::Client.any_instance.stubs(:profile).once.returns(raw)

      assert_equal 'dnm', @linkedin_provider.info.uid
      assert_equal 'Desks Near Me', @linkedin_provider.info.name
      assert_nil @linkedin_provider.info.profile_url
      assert_nil @linkedin_provider.info.website_url
      assert_equal 'https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg', @linkedin_provider.info.image_url

      assert_nil @linkedin_provider.info.hash['uid']
      assert_nil @linkedin_provider.info.hash['nickname']
      assert_equal 'Desks Near Me', @linkedin_provider.info.hash['name']
      assert_nil @linkedin_provider.info.hash['urls']['Linkedin']
      assert_nil @linkedin_provider.info.hash['urls']['Website']
      assert_equal 'https://pbs.twimg.com/profile_images/6457279_n_bigger.jpg', @linkedin_provider.info.hash['image']
    end

    should 'return friend_ids' do
      connections = stub(all: [stub(id: '1'), stub(id: '2')])
      LinkedIn::Client.any_instance.stubs(:connections).once.returns(connections)

      assert_equal ['1', '2'], @linkedin_provider.friend_ids
    end

    
    context 'when token is invalid' do
      setup do
        @linkedin_provider.stubs(:connection).once.raises(LinkedIn::Errors::AccessDeniedError.new(nil))
      end

      should 'rescue and re-raise error when calling friend_ids' do
        assert_raise Authentication::InvalidToken do
          @linkedin_provider.friend_ids
        end
      end

      should 'rescue and re-raise error when calling info' do
        assert_raise Authentication::InvalidToken do
          @linkedin_provider.info
        end
      end
    end
  end
end
