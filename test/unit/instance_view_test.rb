require 'test_helper'

class InstanceViewTest < ActiveSupport::TestCase
  should 'write redis cache info' do
    messages = RedisCache.client.track do
      instance_view = FactoryGirl.create(:instance_view)
    end
    assert messages.any?
    data = JSON.parse messages[0]

    assert data['cache_type'] == 'InstanceView'
    assert data['instance_id'] == PlatformContext.current.instance.id
  end

  should 'inform subscribers about update' do
    instance_view = FactoryGirl.create(:instance_view)
    messages = RedisCache.client.track do
      instance_view.save
    end
    assert messages.any?
  end

  should 'inform subscribers about destroy' do
    instance_view = FactoryGirl.create(:instance_view)
    messages = RedisCache.client.track do
      instance_view.destroy
    end
    assert messages.any?
  end
end
