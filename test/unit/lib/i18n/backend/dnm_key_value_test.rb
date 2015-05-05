require 'test_helper'

class DnmKeyValueTest < ActiveSupport::TestCase

  setup do
    @translation_global = FactoryGirl.create(:translation, :key => 'translation_key', :value => 'global value', instance_id: nil)
    @instance = PlatformContext.current.instance
    FactoryGirl.create(:translation, :key => 'some_key_for_instance', :value => 'default value', instance_id: nil)
    FactoryGirl.create(:translation, :key => 'some_key_for_instance', :value => 'instance value', instance_id: @instance.id)
    @backend = I18n::Backend::DNMKeyValue.new(Rails.cache)
    I18n.locale = :en
    @backend.set_instance_id(@instance.id)
  end

  should 'fallback to global translation' do
    assert_equal 'global value', translate('translation_key')
  end

  should 'handle advanced features ' do
    @translation_global = FactoryGirl.create(:translation, :key => 'advanced.feature.count.one', :value => 'one feature', instance_id: nil)
    @backend.set_instance_id(@instance.id)
    assert_equal({ one: 'one feature' }, translate('advanced.feature.count'))
  end

  should 'update global translation' do
    @translation_global.update_attribute(:value, 'value updated')
    @backend.set_instance_id(@instance.id)
    assert_equal 'value updated', translate('translation_key')
  end

  should 'get translation from given instance' do
    assert_equal 'instance value', translate('some_key_for_instance')
    @backend.set_instance_id(@instance.id + 1)
    assert_equal 'default value', translate('some_key_for_instance')
  end

  should 'dont read from shared cache for consecutive instance requests - use in memory' do
    @backend.expects(:update_store).never
    @backend.set_instance_id(@instance.id)
  end

  should 'read from shared cache for not consecutive instance requests' do
    second_instance_id = FactoryGirl.create(:instance).id
    @backend.expects(:update_store).with(:"#{second_instance_id}").once
    @backend.set_instance_id(second_instance_id)
  end

  should 're-populate cache if it expired' do
    assert_equal 'instance value', translate('some_key_for_instance')
    @backend.set_instance_id(FactoryGirl.create(:instance).id)
    assert_equal 'default value', translate('some_key_for_instance')
    Rails.cache.clear
    @backend.set_instance_id(@instance.id)
    assert_equal 'instance value', translate('some_key_for_instance')
  end

  should 'fallback to default if instance translation is empty' do
    @translation = FactoryGirl.create(:translation, value: "", instance_id: @instance.id)
    @backend.set_instance_id(@instance.id)
    assert_equal 'global value', translate('translation_key')
  end

  should 'fallback to default if instance translation is nil' do
    @translation = FactoryGirl.create(:translation, value: nil, instance_id: @instance.id)
    @backend.set_instance_id(@instance.id)
    assert_equal 'global value', translate('translation_key')
  end

  should 'return another languages' do
    @translation = FactoryGirl.create(:czech_translation, value: 'Jaromír je král', instance_id: @instance.id)
    @backend.set_instance_id(@instance.id)
    I18n.locale = :cs
    assert_equal 'Jaromír je král', translate('translation_key')
  end

  should 'fallback to English if instance language key does not exist' do
    @backend.set_instance_id(@instance.id)
    I18n.locale = :cs
    assert_equal 'global value', translate('translation_key')
  end

  should 'fallback to English if instance language key is empty' do
    @translation = FactoryGirl.create(:czech_translation, value: '', instance_id: @instance.id)
    @backend.set_instance_id(@instance.id)
    I18n.locale = :cs
    assert_equal 'global value', translate('translation_key')
  end

  should 'fallback to English if instance language key is nil' do
    @translation = FactoryGirl.create(:czech_translation, value: nil, instance_id: @instance.id)
    @backend.set_instance_id(@instance.id)
    I18n.locale = :cs
    assert_equal 'global value', translate('translation_key')
  end

  teardown do
    I18n.locale = :en
  end

  protected

  def translate(key, options = {})
    @backend.send(:lookup, I18n.locale, key, nil, options)
  end
end
