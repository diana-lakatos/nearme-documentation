require 'test_helper'

class UserInstanceProfileTest < ActiveSupport::TestCase

  context 'custom attributes' do

    setup do
      @type = FactoryGirl.create(:instance_profile_type)
      @custom_attribute = FactoryGirl.create(:custom_attribute, name: 'custom_profile_attr', label: 'Custom Profile Attr', target: @type, attribute_type: 'string')
      @profile = @type.user_instance_profiles.build
    end

    should 'be able to set value' do
      assert_nothing_raised do
        @profile.custom_profile_attr = 'hello'
        assert_equal 'hello', @profile.custom_profile_attr
      end
    end

  end

end

