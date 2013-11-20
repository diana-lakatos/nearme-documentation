require 'test_helper'

class Authentication::BaseProviderTest < ActiveSupport::TestCase
  class Authentication::TestProvider < Authentication::BaseProvider
  end

  setup do
    @user = stub(:friends => [])
    auth = OpenStruct.new({
      user: @user,
      token: 'abcd',
      secret: 'dcba'
    })

    @provider = Authentication::TestProvider.new(auth)
  end

  context 'initialize' do
    should 'works' do
      assert_kind_of Authentication::TestProvider, @provider
      assert_equal @user, @provider.user
      assert_equal 'abcd', @provider.token
      assert_equal 'dcba', @provider.secret
    end
  end

  context 'new connections' do
    context 'find new friends' do
      setup do
        users_stub = stub(:without => [])
        @provider.stubs(:connections => users_stub)
      end

      should 'for user without friends' do
        @provider.stubs(:user => stub(:friends => []))

        @provider.connections.expects(:without).with([])
        @provider.new_connections
      end

      should 'for user with friend' do
        user = BasicObject.new
        @provider.stubs(:user => stub(:friends => [user]))
        @provider.connections.expects(:without).with([user])
        @provider.new_connections
      end
    end
  end
end
