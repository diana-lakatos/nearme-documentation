require 'test_helper'

class TransactableTypeTest < ActiveSupport::TestCase
  context '#destroying translations' do
    setup do
      @transactable_type = FactoryGirl.create(:transactable_type, name: 'My custom tt')
      @select_attribute = FactoryGirl.create(:custom_attribute, target: @transactable_type, name: 'some_attr', attribute_type: 'string', valid_values: %w(red green blue), html_tag: 'select', prompt: 'my prompt')
    end

    should 'remove old translations when changing name' do
      translations = Translation.where('instance_id = ? AND (key like ? OR key like ?)', PlatformContext.current.instance.id, '%my_custom_tt%', '%my_custom_tts%')
      refute translations.empty?
      @transactable_type.update_attribute(:name, 'my new name')
      translations = Translation.where('instance_id = ? AND (key like ? OR key like ?)', PlatformContext.current.instance.id, '%my_custom_tt%', '%my_custom_tts%')
      assert translations.empty?, 'Expected old translations to be deleted'
    end

    should 'create new translations' do
      assert_no_difference 'Translation.count' do
        @transactable_type.update_attribute(:name, 'My new name')
      end
      translations = Translation.where('instance_id = ? AND (key like ? OR key like ?)', PlatformContext.current.instance.id, '%my_new_name%', '%my_new_name%')
      refute translations.empty?, 'Expected new translations to be created'
    end

    should 'not destroy random translations' do
      t1 = FactoryGirl.create(:translation, instance_id: PlatformContext.current.instance.id, key: 'random.translation_my_custom_tt_suffix')
      t2 = FactoryGirl.create(:translation, instance_id: PlatformContext.current.instance.id, key: 'random.my_custom_tt')
      t3 = FactoryGirl.create(:translation, instance_id: PlatformContext.current.instance.id, key: 'random.my_custom_tt.something')
      @transactable_type.update_attribute(:name, 'My new name')
      assert t1.reload.present?
      assert t2.reload.present?
      assert t3.reload.present?
    end
  end
end
