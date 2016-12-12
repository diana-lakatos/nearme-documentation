require 'test_helper'

class DnmKeyValueTest < ActiveSupport::TestCase
  setup do
    I18n.locale = :en
    @instance = PlatformContext.current.instance
    @translation_global = FactoryGirl.create(:translation, key: 'translation_key', value: 'global value', instance_id: nil)
    @default_translation = FactoryGirl.create(:translation, key: 'some_key_for_instance', value: 'default value', instance_id: nil)
    @instance_translation = FactoryGirl.create(:translation, key: 'some_key_for_instance', value: 'instance value', instance_id: @instance.id)
    @backend = I18N_DNM_BACKEND
    @backend.rebuild!
    @backend.set_instance(@instance)
    @backend.update_cache(@instance.id)
  end

  should 'handle advanced features ' do
    @translation_global = FactoryGirl.create(:translation, key: 'advanced.feature.count.one', value: 'one feature', instance_id: nil)
    @backend.update_defaults
    assert_equal({ one: 'one feature' }, translate('advanced.feature.count'))
  end

  should 'update global translation' do
    @translation_global.update_attribute(:value, 'value updated')
    assert_equal 'global value', translate('translation_key')
    # need to clear default cache before this works
    @backend.update_defaults
    assert_equal 'value updated', translate('translation_key')
  end

  # TODO: we do not have deleted feature, but this is to remember about unit test if we add it ;)
  # should 'be able to notice translation was deleted' do
  #  @instance_translation.destroy
  #  @backend.update_cache(@instance.id)
  #  assert_equal 'default value', translate('some_key_for_instance')
  # end

  should 'get translation from given instance' do
    assert_equal 'instance value', translate('some_key_for_instance')
    @backend.set_instance(FactoryGirl.create(:instance))
    assert_equal 'default value', translate('some_key_for_instance')
  end

  should 're-populate cache if it expired' do
    assert_equal 'instance value', translate('some_key_for_instance')
    @backend.set_instance(FactoryGirl.create(:instance))
    assert_equal 'default value', translate('some_key_for_instance')
    @backend.set_instance(@instance)
    assert_equal 'instance value', translate('some_key_for_instance')
  end

  should 'fallback to default if instance translation is empty' do
    @translation = FactoryGirl.create(:translation, value: '', instance_id: @instance.id)
    assert_equal 'global value', translate('translation_key')
  end

  should 'fallback to default if instance translation is nil' do
    @translation = FactoryGirl.create(:translation, value: nil, instance_id: @instance.id)
    assert_equal 'global value', translate('translation_key')
  end

  should 'return another languages' do
    I18n.locale = :cs
    @translation = FactoryGirl.create(:czech_translation, value: 'Jaromír je král', instance_id: @instance.id)
    assert_equal 'Jaromír je král', translate('translation_key')
  end

  should 'fallback to English if instance language key does not exist' do
    I18n.locale = :cs
    assert_equal 'global value', translate('translation_key')
  end

  should 'fallback to English if instance language key is empty' do
    I18n.locale = :cs
    @translation = FactoryGirl.create(:czech_translation, value: '', instance_id: @instance.id)
    assert_equal 'global value', translate('translation_key')
  end

  should 'fallback to English if instance language key is nil' do
    I18n.locale = :cs
    @translation = FactoryGirl.create(:czech_translation, value: nil, instance_id: @instance.id)
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
