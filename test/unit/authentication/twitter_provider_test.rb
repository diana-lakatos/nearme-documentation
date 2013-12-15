require 'test_helper'

class Authentication::TwtterProviderTest < ActiveSupport::TestCase

  setup do
    auth = OpenStruct.new({
      user: FactoryGirl.create(:user),
      token: 'abcd',
      secret: 'dcba'
    })
    @twitter_provider = Authentication::TwitterProvider.new(auth)
  end

  context 'rate error' do
    should 'be rescued and ignored' do
      @twitter_client_stub = mock()
      @twitter_provider.stubs(:connection).returns(@twitter_client_stub)
      @twitter_client_stub.stubs(:friend_ids).raises(Twitter::Error::TooManyRequests)
      assert_nothing_raised do
        @twitter_provider.friend_ids
      end
    end

  end


end
