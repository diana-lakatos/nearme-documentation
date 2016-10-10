require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  context '#render_social_connection' do
    should 'return empty string without connection' do
      user = stub
      connection = nil
      assert_equal '', render_social_connection(user, connection)
    end

    context 'render registrations/social_connection with correct params' do
      setup do
        @user = stub(social_url: 'link')
      end

      should 'for facebook' do
        connection = stub(provider: 'facebook', count: '6')
        expects(:render).with('registrations/social_connection', icon: 'ico-facebook-full', provider: 'facebook', count: 6, link: 'link').returns(nil)
        render_social_connection(@user, connection)
      end

      should 'for another' do
        connection = stub(provider: 'linkedin', count: '6')
        expects(:render).with('registrations/social_connection', icon: 'ico-linkedin', provider: 'linkedin', count: 6, link: 'link').returns(nil)
        render_social_connection(@user, connection)
      end
    end
  end
end
