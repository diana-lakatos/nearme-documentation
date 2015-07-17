require 'test_helper'

class TranslationTest < ActiveSupport::TestCase

  should belong_to(:instance)

    should 'inform subscribers about create' do
      messages = NearMeMessageBus.track_publish do
        translation = FactoryGirl.create(:translation)
      end
      assert messages.any?
      assert messages[0].channel == '/cache_expiration'
      assert messages[0].data[:cache_type] == 'Translation'
      assert messages[0].data[:instance_id] == PlatformContext.current.instance.id
    end

    should 'inform subscribers about update' do
      translation = FactoryGirl.create(:translation)
      messages = NearMeMessageBus.track_publish do
        translation.save
      end
      assert messages.any?
    end

    should 'inform subscribers about destroy' do
      translation = FactoryGirl.create(:translation)
      messages = NearMeMessageBus.track_publish do
        translation.destroy
      end
      assert messages.any?
    end

end
