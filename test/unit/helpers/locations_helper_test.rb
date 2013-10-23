require 'test_helper'

class LocationsHelperTest < ActionView::TestCase
  include LocationsHelper

  context '#user_can_edit_location?' do
    setup do
      @location = stub(:is_user_admin?)
    end

    context 'with nil user' do
      should 'return false immidiately' do
        @location.expects(:is_user_admin?).never
        refute user_can_edit_location?(nil, @location)
      end
    end

    context 'with valid params' do
      setup do
        @user = stub
      end

      should 'return true' do
        @location.expects(:is_user_admin?).once.returns(true)
        assert user_can_edit_location?(@user, @location)
      end

      should 'return false' do
        @location.expects(:is_user_admin?).once.returns(false)
        refute user_can_edit_location?(@user, @location)
      end
    end
  end
end
