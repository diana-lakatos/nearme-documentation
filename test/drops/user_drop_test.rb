require 'test_helper'

class UserDropTest < ActionView::TestCase
  context 'with one message sent to listings creator' do
    setup do
      @instance = FactoryGirl.create(:instance)
      @author = FactoryGirl.create(:user).to_liquid
      PlatformContext.current = PlatformContext.new(@instance)
    end

    context '#social_connections_for' do
      should 'return nil for unexisting connection' do
        @author.expects(:social_connections).returns([])
        assert !@author.facebook_connections
      end

      should 'return connection for existing connection' do
        connection = stub(provider: 'facebook')
        @author.expects(:social_connections).returns([connection])
        assert @author.facebook_connections
      end
    end
  end
end
