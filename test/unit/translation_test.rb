require 'test_helper'

class TranslationTest < ActiveSupport::TestCase

  should belong_to(:instance)

  context 'for instance' do

    setup do
      @translation_global = FactoryGirl.create(:translation, instance_id: nil)
    end

    should 'fallback to global translation' do
      assert_equal I18n.t('translation_key'), @translation_global.value
    end

    should 'get translation from given instance' do
      instance = FactoryGirl.create(:instance)
      second_instance = FactoryGirl.create(:instance)
      I18n.backend.backends.first.instance_id = instance.id

      translation = FactoryGirl.create(:translation, value: 'value_2', instance_id: instance.id)
      FactoryGirl.create(:translation, value: 'value_3', instance_id: second_instance.id)

      assert_equal I18n.t('translation_key'), 'value_2'
    end
  end

end
