require 'test_helper'

class LocaleTest < ActiveSupport::TestCase
  should 'prevent deleting default locale' do
    default_locale = FactoryGirl.create(:primary_locale, code: 'cs')
    refute default_locale.destroy
    assert_equal ["You can't delete default locale"], default_locale.errors[:base]
  end

  should 'reset other default locales' do
    default_locale = FactoryGirl.create(:primary_locale)
    FactoryGirl.create(:primary_locale, code: 'cs')
    default_locale.reload
    refute default_locale.primary?
  end

  should 'prevent deleting English locale' do
    locale = FactoryGirl.create(:locale)
    refute locale.destroy
    assert_equal ["You can't delete English locale"], locale.errors[:base]
  end

  should 'delete all instance keys for locale' do
    locale = FactoryGirl.create(:locale, code: 'cs')
    FactoryGirl.create(:czech_translation, instance_id: 1)
    locale.destroy
    assert_equal 0, Translation.where(locale: locale.code).count
  end

  should 'set proper user language when deleted' do
    FactoryGirl.create(:primary_locale, code: 'en')
    locale = FactoryGirl.create(:locale, code: 'cs')
    FactoryGirl.create(:user, language: 'cs')

    assert_difference 'User.where(language: "cs").count', -1 do
      assert locale.destroy
    end
  end
end
