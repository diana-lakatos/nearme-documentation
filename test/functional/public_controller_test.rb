require 'test_helper'

class PublicControllerTest < ActionController::TestCase

  context 'GET index' do

    context 'i18n' do

      setup do
        @translation_global = FactoryGirl.create(:translation, :key => 'translation_key', :value => 'global value', instance_id: nil)
        @instance = Instance.default_instance
      end

      should 'fallback to global translation' do
        get :index
        assert_equal 'global value', I18n.t('translation_key')
      end

      should 'get translation from given instance' do
        FactoryGirl.create(:translation, value: 'value_2', instance_id: @instance.id)
        second_instance = FactoryGirl.create(:instance)
        FactoryGirl.create(:translation, value: 'value_3', instance_id: second_instance.id)
        get :index
        assert_equal 'value_2', I18n.t('translation_key')
        PlatformContext.any_instance.stubs(:instance).returns(second_instance)
        get :index
        assert_equal 'value_3', I18n.t('translation_key')
      end

      should 'fallback to default if instance translation is empty' do
        @translation = FactoryGirl.create(:translation, value: "", instance_id: @instance.id)
        get :index
        assert_equal 'global value', I18n.t('translation_key')
      end

      should 'fallback to default if instance translation is nil' do
        @translation = FactoryGirl.create(:translation, value: nil, instance_id: @instance.id)
        assert_equal 'global value', I18n.t('translation_key')
      end

    end

  end
end
