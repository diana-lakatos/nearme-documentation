require 'test_helper'

class InstanceViewTest < ActiveSupport::TestCase

    should 'inform subscribers about create' do
      messages = NearMeMessageBus.track_publish do
        instance_view = FactoryGirl.create(:instance_view)
      end
      assert messages.any?
      assert messages[0].channel == '/cache_expiration'
      assert messages[0].data[:cache_type] == 'InstanceView'
      assert messages[0].data[:instance_id] == PlatformContext.current.instance.id
    end

    should 'inform subscribers about update' do
      instance_view = FactoryGirl.create(:instance_view)
      messages = NearMeMessageBus.track_publish do
        instance_view.save
      end
      assert messages.any?
    end

    should 'inform subscribers about destroy' do
      instance_view = FactoryGirl.create(:instance_view)
      messages = NearMeMessageBus.track_publish do
        instance_view.destroy
      end
      assert messages.any?
    end

end
