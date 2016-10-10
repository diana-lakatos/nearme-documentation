require 'test_helper'

class TranslationTest < ActiveSupport::TestCase
  should belong_to(:instance)

  should 'inform subscribers about create' do
    messages = RedisCache.client.track do
      translation = FactoryGirl.create(:translation)
    end
    assert messages.any?
    data = JSON.parse messages[0]
    assert data['cache_type'] == 'Translation'
    assert data['instance_id'] == PlatformContext.current.instance.id
  end

  should 'inform subscribers about update' do
    translation = FactoryGirl.create(:translation)
    messages = RedisCache.client.track do
      translation.save
    end
    assert messages.any?
  end

  should 'inform subscribers about destroy' do
    translation = FactoryGirl.create(:translation)
    messages = RedisCache.client.track do
      translation.destroy
    end
    assert messages.any?
  end
end
